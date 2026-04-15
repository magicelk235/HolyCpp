; reserve place in the stack
; ress(size) 
%macro ress 1
    sub rsp,%1

    %assign __locals_%[procName] locals(procName)+%1
    
    %assign %%offset heldSize(procName)+locals(procName)
    retm rbp-%%offset
%endmacro

; new local var in a proc
; newl(name,size,times,depth)
%macro newl 4
    %assign %%size %2
    %if %4>0
        %assign %%size 8
    %endif
    %if %3==1
        ress %%size
    %else
        ress %%size*%3
        ress arraySizeOffset
        omov qword [__1],%%size*%3
    %endif
%endmacro

; custom arg in a proc
; arg(name, size,times,depth)
%macro arg 4
    %assign %%size %2
    %if %4>0
        %assign %%size 8
        retm rbp+%eval(args(procName)+8)
    %endif

    %assign __args_%[procName] %eval(args(procName)+align(%3*%%size) + (%3>1)*8)
    retm rbp+%eval(args(procName)+8)
%endmacro

; gloabl push
; push
%macro push 1-*
    %rep %0
        %rotate -1
        TokenToNum %1
        %ifnum __1
            %if isNumInSize(__1,4)
                push qword __1
            %else
                mov rax,__1
                push rax
            %endif
        %elif isRef(%1)
            %if isDirectRef(%1)
                %if times(%1)>1
                    addrOf %1,rax,"",0
                    %xdefine %%addr __1
                    
                    %assign %%byteSize times(%1)*size(%1)
                    %assign %%totalByteSize align(%%byteSize)+8
                    %assign %%rspOffset %%totalByteSize
                    %assign %%arrayOffset 8

                    ; mov the arrays size
                    mov [rsp-%%rspOffset],[%%addr],8,8
                    %assign %%rspOffset %%rspOffset-8
                    

                    %rep times(%1)
                        mov [rsp-%%rspOffset],[%%addr+%%arrayOffset],size(%1),size(%1)
                        %assign %%arrayOffset %%arrayOffset+size(%1)
                        %assign %%rspOffset %%rspOffset-size(%1)
                    %endrep
                    sub rsp,%%totalByteSize
                %else
                    lxd %1,rbp
                    push qword __1
                %endif
            %else
                lxd %1,rbp
                push qword __1
            %endif
        %elif isReg(%1)
            %if size(%1)!=8
                %assign %%size (size(%1)/8) * 8
                %assign %%size (size(%1) % 8!=0? 8 : %%size)
                sub rsp,%%size
                mov [rsp],%1,8,size(%1)
            %else
                push %1
            %endif
        %else
            push qword %1
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
    %xdefine __addr_%1 __proc_%1
    %assign __outs_%1 %2*8
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
    global __proc_%+procName
    __proc_%+procName:
    %assign forceMov 1
    push rbp
    mov rbp,rsp
    %assign forceMov 0
    %if %0 == 2
        newProc procName,%2
    %else
        newProc procName,0
    %endif
    %define inProc 1
    new arg qword argc
    newRef argv,8,addr(argc),0,0,1
%endmacro

%define align(x) %eval(((x)/8 + (((x) % 8)!=0))*8)

; smart call, automatically handles pushing args and poping outs
; callp(procName,args,out)
%macro callp 1-*
    %define %%procName %1
    %if !%isnum(outs(%%procName))
        %error %%procName does not exists
        %exitmacro
    %endif
    %assign %%outs outs(%%procName)
    %assign %%outsCount %%outs/8
    %assign %%totalArgs %0-%%outsCount ; total macros args - outs - procName(1) + argc(1)
    %assign %%givenArgs %%totalArgs-1

    ; procname,arg1,arg2,out1,out2
    %rotate 1
    ; arg1,arg2,out1,out2,procname
    %assign %%totalArgsSize 8 ; argc(8)
    %rep %%givenArgs
        %if isRef(%1)
            %if isTokenIndex(%1)
                splitIndex %1
                %assign %%totalArgsSize %%totalArgsSize+align(size(__1))
            %else
                %if times(%1)>1
                    %assign %%totalArgsSize %%totalArgsSize+align(times(%1)*size(%1)+8)
                %else
                    %assign %%totalArgsSize %%totalArgsSize+align(size(%1))
                %endif
            %endif
        %elifnum size(%1)
            %assign %%totalArgsSize %%totalArgsSize+align(size(%1))
        %else
            %assign %%totalArgsSize %%totalArgsSize+8
        %endif
        %rotate 1
    %endrep
    ; out1,out2,procname,arg1,arg2

    %rotate %%outsCount
    ; procname,arg1,arg2,out1,out2

    ; outs - total args
    %assign %%neededSpace max(%%outs+procClean(%%procName)-%%totalArgsSize,0)

    ; arg2,arg1,rax,count

    ; pushes trash to reserve space for out
    %if %%neededSpace>0
        sub rsp,%%neededSpace
    %endif
    ; procname,arg1,arg2,out1,out2
    ; pushes in N-1 order
    ; rotates that %N is the last arg
    %rotate -%%outsCount
    ; out1,out2,procname,arg1,arg2
    %rep %%givenArgs
        %rotate -1
        push %1
    %endrep
    ; arg2,out1,out2,procname,arg1
    ; arg1,arg2,out1,out2,procname

    ; pushes the byte count of the args without argc
    push %eval(%%totalArgsSize-8)

    ocall addr(%%procName)
    ; arg1,arg2,out1,out2,procname
    %rotate -1
    ; procname,arg1,arg2,out1,out2
    %rep %%outsCount
        %rotate -1
        pop %1
    %endrep
    ; total stack - outs - procClean
    %assign %%clear %%totalArgsSize-%%outs-procClean(%%procName)
    ; if the proc got more data the usual clean it
    %if %%clear>0
        add rsp,%%clear
    %endif

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
    %assign __procClean_%[procName] max(args(procName) - outs(procName),0)
    pop rbp
    ret procClean(procName)
    %pop
    %define inProc 0
%endmacro


; return's values from a proc
; return(out[])
%macro return 0-*
    %assign %%args max(args(procName),outs(procName))+8

    %assign %%stackcount 0
    %assign %%currentOut 0
    %rep %0
        %if %%stackcount==0
            %assign %%currentOut %%currentOut+1
            %xdefine %%o_%[%%currentOut] %1
        %else
            %xdefine %%o_%[%%currentOut] %%o_%[%%currentOut]%+:%+%1
        %endif
        findInToken %1,"("
        %assign %%stackcount %%stackcount+__1
        findInToken %1,"["
        %assign %%stackcount %%stackcount+__1

        findInToken %1,"]"
        %assign %%stackcount %%stackcount-__1   
        findInToken %1,")"
        %assign %%stackcount %%stackcount-__1
        %rotate 1
    %endrep

    
    %assign %%outc %%currentOut
    %assign %%currentOut 1
    %assign %%out 0
    %rep %%outc
        eval %%o_%[%%currentOut]
        %assign forceMov 1
        mov [rbp+%eval(%%args-%%out*8)],__1,8
        %assign forceMov 0
        endEval
        %assign %%out %%out+1
        %assign %%currentOut %%currentOut+1
    %endrep
    jmp %[procName]exit
%endmacro