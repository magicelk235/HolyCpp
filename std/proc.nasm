

; reserve place in the stack
; ress(varSize, varName, ref?) 
%macro ress 1-3
    %assign %%qwordSize %1 / 8
    
    %if %1 % 8 != 0
        %assign %%qwordSize %%qwordSize + 1
    %endif
    
    sub rsp,%eval(%%qwordSize*8)
    
    %assign %$locals %$locals + %%qwordSize * 8
    
    %if %0 = 3
        desc %2,%1, rbp %eval(blackboxOffset-%$locals),%3
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
        mov %1,%2*%3,8,8
    %endif
%endmacro

; custom arg in a proc
; arg(name, size,isRef?)
%macro arg 2-3
    %assign %$args %$args + 8
    %if %0 = 2
        desc %1,%2,rbp+%eval(%$args+8),0
    %else
        desc %1,%2,[rbp+%eval(%$args+8)],1
    %endif
%endmacro

; gloabl push
; push
%macro push 1-*
    %rep %0
        %rotate -1
        TokenToNum %1
        %ifnum __0
            push qword __0
        %else
            %ifnum isPtr(%1)
                %if isPtr(%1)=1
                    mov [rsp-16],r15
                    lea r15,%1
                    push r15
                    mov r15,[rsp-8]
                %else
                    push qword [ref(%1)]
                %endif
            %else
                %if size(%1)!=8
                    %assign %%size (size(%1)/8) * 8
                    %assign %%size (size(%1) % 8!=0? 8 : %%size)
                    sub rsp,%%size
                    mov [rsp],%1,8,size(%1)
                %else
                    push %1
                %endif
            %endif
        %endif
    %endrep
%endmacro

; gloabl pop
; pop
%macro pop 1-*
    %rep %0
        %if size(%1) == 8
            %ifnum group(%1)
                pop %1
            %else
                pop qword [ref(%1)]
            %endif
        %else
            %ifnum group(%1)
                %assign %%size (size(%1)/8) * 8
                %assign %%size (size(%1) % 8!=0? 8 : %%size)
                mov %1,[rsp],size(%1),8 
                add rsp,%%size
            %else
                mov [rsp-8],r15
                mov r15,[rsp]
                mov %1,r15
                mov r15,[rsp-8]
                add rsp,8
            %endif 
        %endif
        %rotate 1
    %endrep
%endmacro


%define blackboxOffset %eval(-8*14 -16*8)

%define inProc 0

; defines a new proc
; proc(name,?outCount)
%macro proc 1-2
    %push
    %define %$procName %1
    global %$procName
    %$procName:
    push rbp
    mov rbp,rsp
    push rax,rbx,rcx,rdx,rsi,rdi,r8,r9,r10,r11,r12,r13,r14,r15,xmm0,xmm1,xmm2,xmm3,xmm4,xmm5,xmm6,xmm7
    %assign %$locals 0
    %assign %$args 0
    %define %$out %[%$procName] %+ out
    %if %0 == 2
        %assign %$out %2*8
    %else
        %assign %$out 0
    %endif
    %define inProc 1
%endmacro

%assign tempOffset 0
; newt(name,size)
%macro newt 2
    %assign tempOffset tempOffset+%2
    desc %1,%2,rbp+tempOffset,0
%endmacro

%macro resetTemp 0
    %if inProc
        %assign tempOffset blackboxOffset+%$locals
    %else
        %assign tempOffset 0
%endmacro

; defines the end of a proc
; endp
%macro endp 0
    %$exit:
    add rsp, %$locals
    pop rax,rbx,rcx,rdx,rsi,rdi,r8,r9,r10,r11,r12,r13,r14,r15,xmm0,xmm1,xmm2,xmm3,xmm4,xmm5,xmm6,xmm7
    pop rbp
    ret %eval(%$args-%$out)
    %pop
    %define inProc 0
%endmacro

; smart call, automatically handles pushing args and poping outs
; call(procName,args,out)
%macro call 1-*
    %define %%procName %1
    %assign %%out %[%%procName %+ out]
    %assign %%out %%out/8
    %assign %%args %0-%%out-1    

    ; pushes trash to reserve space for out
    %if %%out>%%args
        %rep %%out-%%args
            push rax
        %endrep
    %endif


    %rotate -%%out
    %rep %%args
        %rotate -1
        push %1
    %endrep

    call %%procName

    %rotate -1
    %rep %%out
        %rotate -1
        pop %1
    %endrep
        
%endmacro


; return's values from a proc
; retp(out[])
%macro retp 0-*
    %if %$out>%$args
        %assign %$args %$out
    %endif

    %assign %%out 0
    %rep %0        
        %ifnum group(%1)
            mov [rbp + %eval(%$args+8-%%out)],%1,8,size(%1)
        %else
            mov rax, %1
            mov [rbp + %eval(%$args+8-%%out)],rax
        %endif
        %assign %%out %%out+8
        %rotate 1
    %endrep
    jmp %$exit
%endmacro