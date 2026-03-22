; reserve place in the stack
; ress(size, name, ref?) 
%macro ress 1-3
    sub rsp,%1

    %assign __locals_%[procName] locals(procName)+%1
    
    %if %0 = 3
        %assign %%offset heldSize(procName)+locals(procName)
        newRef %2,%1, rbp-%%offset ,%3
    %endif
%endmacro

; new local var in a proc
; newl(name,size,times)
%macro newl 2-3
    %if %0 = 2
        ress %2,%1,0
    %else
        ress %2*%3
        ress listSizeOffset,%1,0
        %assign __size_%+%1 %2
        mov %1,%3,8,8
    %endif
%endmacro

; custom arg in a proc
; arg(name, size,isRef?)
%macro arg 2-3
    %assign __args_%[procName] args(procName)+1
    %if %0 = 2
        newRef %1,%2,rbp+%eval(args(procName)*8+8),0
    %else
        newRef %1,%2,[rbp+%eval(args(procName)*8+8)],1
    %endif
%endmacro

; gloabl push
; push
%macro push 1-*
    %rep %0
        %rotate -1
        TokenToNum %1
        %ifnum __1
            push qword __1
        %elif isRef(%1)
            lxd %1,rax
            push qword __1
        %elif size(%1)!=8
            %assign %%size (size(%1)/8) * 8
            %assign %%size (size(%1) % 8!=0? 8 : %%size)
            sub rsp,%%size
            mov [rsp],%1,8,size(%1)
        %else
            push %1
        %endif
    %endrep
%endmacro

; gloabl pop
; pop
%macro pop 1-*
    %rep %0
        %if isReg(%1)
            %if size(%1)!=8
                %assign %%size (size(%1)/8) * 8
                %assign %%size (size(%1) % 8!=0? 8 : %%size)
                mov %1,[rsp],size(%1),8
                add rsp,%%size
            %else
                pop %1
            %endif
        %else
            mov %1,[rsp]
            add rsp,8
        %endif
        %rotate 1
    %endrep
%endmacro


%define inProc 0

%define @ext r8,r9,r10,r11,r12,r13,r14,r15
%define @general rax,rbx,rcx,rdx,rsi,rdi 
%define @float xmm1,xmm2,xmm3,xmm4,xmm5,xmm6,xmm7
%define @all @general,@ext,@float

; name,out
%macro newProc 2
    %assign __outs_%1 %2
    %assign __args_%1 0
    %assign __heldSize_%1 0
    %define __held_%1 -1
    %assign __locals_%1 0
    %assign __procClean_%1 0
%endmacro

%define locals(x) __locals_ %+ x
%define args(x) __args_ %+ x
%define outs(x) __outs_%+ x
%define heldSize(x) __heldSize_ %+ x
%define held(x) __held_ %+ x
%define procClean(x) __procClean_ %+ x

%macro hold 1-*
    sumSize %{1:-1}
    %assign __heldSize_%[procName] __1
    %xdefine __held_%[procName] %{1:-1}
    push %{1:-1}
%endmacro

; defines a new proc
; proc(name,?outCount)
%macro proc 1-2
    %push 
    %define procName %1
    %define %$blockType "proc"
    global procName
    procName:
    push rbp
    mov rbp,rsp
    %if %0 == 2
        newProc procName,%2
    %else
        newProc procName,0
    %endif
    %define inProc 1
    arg argc,8
    newRef argv,8,addr(argc),0
%endmacro

; start
%assign tempRbpOffset 0
; count
%assign tempRbpVariables 0
; allocated
%assign tempRbpAllocated 96

; newtbp(name,size)
%macro newtbp 2
    %assign tempRbpOffset tempRbpOffset+%2
    %assign tempRbpVariables tempRbpVariables+%2
    %if tempRbpVariables>tempRbpAllocated
        %assign tempRbpAllocated tempRbpAllocated+32
        sub rsp,32
    %endif
    newRef %1,%2,rbp-tempRbpOffset,0
%endmacro

%macro startTempBp 0
    %assign tempRbpVariables 0
    %assign tempRbpAllocated 96
    %if inProc
        %assign tempRbpOffset locals(procName)+heldSize(procName)
    %else
        %assign tempRbpOffset 0
        push rbp
        mov rbp,rsp
    %endif
    sub rsp,tempRbpAllocated
%endmacro

%macro endTempBp 0
    add rsp,tempRbpAllocated
    %if !inProc
        pop rbp
    %endif
%endmacro

%macro startTempSp 0
    %assign tempSpVariables 0
%endmacro

%macro newtSp 2
    %assign tempSpVariables tempSpVariables+%2
    newRef %1,%2,rsp-tempSpVariables,0
%endmacro

; defines the end of a proc
; endp
%macro endp 0
    %[procName]exit:
    %if locals(procName)!=0
        add rsp, locals(procName)
    %endif
    %if heldSize(procName)
        pop held(procName)
    %endif
    %assign __procClean_%[procName] max((args(procName) - outs(procName))*8,0)
    pop rbp
    ret procClean(procName)
    %pop
    %define inProc 0
%endmacro

; smart call, automatically handles pushing args and poping outs
; call(procName,args,out)
%macro call 1-*
    %define %%procName %1
    %assign %%outs outs(%%procName)
    %assign %%totalArgs %0-%%outs ; total macros args - outs - procName(1) + argc(1)
    %assign %%givenArgs %%totalArgs-1 
    %assign %%procArgs args(%%procName)
    %assign %%neededSpace max((%%outs-%%givenArgs-1)*8,0) ; outs - total args

    ; arg2,arg1,rax,count

    ; pushes trash to reserve space for out
    %if %%neededSpace>0
        sub rsp,%%neededSpace
    %endif
    ; name,arg1,arg2,arg3,out1,out2 ->
    ; out2,out1,name,arg1,arg2,arg3
    ; pushes in N-1 order
    ; rotates that %N is the last arg
    %rotate -%%outs
    %rep %%givenArgs
        %rotate -1
        push %1
    %endrep
    ; pushes the count of the args
    push %%givenArgs

    call %%procName
    ; arg1,arg2,arg3,out2,out1,name ->
    ; name,arg1,arg2,arg3,out2,out1
    %rotate -1
    %rep %%outs
        %rotate -1
        pop %1
    %endrep
    ; total stack - outs - procClean
    %assign %%clear (max(%%totalArgs,%%outs)-%%outs)*8-procClean(%%procName)
    ; if the proc got more data the usual clean it
    %if %%clear
        add rsp,%%clear
    %endif

%endmacro


; return's values from a proc
; retp(out[])
%macro retp 0-*

    %assign %%args args(procName)
    %if %%args<outs(procName)
        %assign %%args outs(procName)
    %endif 
    %assign %%args %%args+1
    

    %assign %%out 0
    %rep %0
        let [rbp+%eval((%%args-%%out)*8)],%1
        %assign %%out %%out+1
        %rotate 1
    %endrep
    jmp %[procName]exit
%endmacro