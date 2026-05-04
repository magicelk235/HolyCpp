; reserve place in the stack
; ress(size) 
%macro ress 1
    sub rsp,%1
    %assign __locals_%[procName] locals(procName)+%1
    %assign %?offset heldSize(procName)+locals(procName)
    retm rbp-%?offset
%endmacro

; new local var in a proc
; newl(name,size,times,depth)
%macro newl 4
    %assign %?size %2
    %if %4>0
        %assign %?size 8
    %endif
    ress %?size*%3
%endmacro

; custom arg in a proc
; arg(name, size,times,depth)
%macro arg 4
    %assign %?size %2
    %if %4>0
        %assign %?size 8
        retm rbp+%eval(args(procName)+8)
    %endif

    %assign __args_%[procName] %eval(args(procName)+__macro_align8(%3*%?size))
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
                %if listIndex(shape(%1),0)>1
                    addrOf %1,rax,"",0
                    %xdefine %?addr __1

                    %assign %?actualSize totalSize(%1)
                    %assign %?totalByteSize __macro_align8(%?actualSize)
                    %assign %?remainder %?actualSize % 8
                    %assign %?rspOffset %?totalByteSize
                    %assign %?arrayOffset 0

                    %rep %?actualSize/16
                        movdqu xmm0,[%?src+%?arrayOffset]
                        movdqu [%?dest+%?rspOffset],xmm0
                        %assign %?arrayOffset %?arrayOffset+16
                        %assign %?rspOffset %?rspOffset-16
                    %endrep
                    %assign %?actualSize %?actualSize % 16

                    %rep %?actualSize/8
                        omov rax,[%?src+%?arrayOffset]
                        omov [%?dest+%?rspOffset],rax
                        %assign %?arrayOffset %?arrayOffset+8
                        %assign %?rspOffset %?rspOffset-8
                    %endrep
                    %assign %?actualSize %?actualSize % 8

                    %rep %?actualSize/4
                        omov eax,[%?src+%?arrayOffset]
                        omov [%?dest+%?rspOffset],eax
                           %assign %?arrayOffset %?arrayOffset+4
                        %assign %?rspOffset %?rspOffset-4
                    %endrep

                    %assign %?actualSize %?actualSize % 4
                    %rep %?actualSize/2
                        mov ax,[%?src+%?arrayOffset]
                        mov [%?dest+%?rspOffset],ax
                        %assign %?arrayOffset %?arrayOffset+2
                        %assign %?rspOffset %?rspOffset-2
                    %endrep

                    %if %?actualSize % 2
                        mov al,[%?src+%?arrayOffset]
                        mov [%?dest+%?rspOffset],al
                    %endif
                    sub rsp,%?totalByteSize

                %else
                    sizeByToken %1
                    %if __1==8
                        lxd %1,rbp
                        push qword __1
                    %else
                        mov rax,%1
                        push rax
                    %endif
                %endif
            %else
                sizeByToken %1
                %if __1==8
                    lxd %1,""
                    push qword __1
                %else
                mov rax,%1
                push rax
                %endif
            %endif
        %elif isReg(%1)
            %if size(%1)!=8
                %assign %?size (size(%1)/8) * 8
                %assign %?size (size(%1) % 8!=0? 8 : %?size)
                sub rsp,%?size
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
                %assign %?size (size(%1)/8) * 8
                %assign %?size (size(%1) % 8!=0? 8 : %?size)
                mov %1,[rsp],size(%1),8
                add rsp,%?size
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
%define isProc(x) %isnum(locals(x))

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
    %macro %[procName] 1-*
        call %?%{1:-1}
    %endmacro

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
    newRef argv,8,addr(argc)+8,0,0,1,1
%endmacro

%define __macro_align8(x) %eval(((x)/8 + (((x) % 8)!=0))*8)

; smart call, automatically handles pushing args and poping outs
; callp(procName,args,out)
%macro callp 1-*
    %define %?procName %1
    %if !%isnum(outs(%?procName))
        %error %?procName does not exists
        %exitmacro
    %endif
    %assign %?outs outs(%?procName)
    %assign %?outsCount %?outs/8
    %assign %?totalArgs %0-%?outsCount ; total macros args - outs - procName(1) + argc(1)
    %assign %?givenArgs %?totalArgs-1

    ; procname,arg1,arg2,out1,out2
    %rotate 1
    ; arg1,arg2,out1,out2,procname
    %assign %?totalArgsSize 8 ; argc(8)
    %rep %?givenArgs
        %if isRef(%1)
            removeIndex %1
            %assign %?totalArgsSize %?totalArgsSize+__macro_align8(size(__1))
        %elifnum size(%1)
            %assign %?totalArgsSize %?totalArgsSize+__macro_align8(size(%1))
        %else
            %assign %?totalArgsSize %?totalArgsSize+8
        %endif
        %rotate 1
    %endrep
    ; out1,out2,procname,arg1,arg2

    %rotate %?outsCount
    ; procname,arg1,arg2,out1,out2

    ; outs - total args
    %assign %?neededSpace __macro_max(%?outs+procClean(%?procName)-%?totalArgsSize,0)

    ; arg2,arg1,rax,count

    ; pushes trash to reserve space for out
    %if %?neededSpace>0
        sub rsp,%?neededSpace
    %endif
    ; procname,arg1,arg2,out1,out2
    ; pushes in N-1 order
    ; rotates that %N is the last arg
    %rotate -%?outsCount
    ; out1,out2,procname,arg1,arg2
    %rep %?givenArgs
        %rotate -1
        push %1
    %endrep
    ; arg2,out1,out2,procname,arg1
    ; arg1,arg2,out1,out2,procname

    ; pushes the byte count of the args without argc
    push %eval(%?totalArgsSize-8)

    ocall addr(%?procName)
    ; arg1,arg2,out1,out2,procname
    %rotate -1
    ; procname,arg1,arg2,out1,out2
    %rep %?outsCount
        %rotate -1
        pop %1
    %endrep
    ; total stack - outs - procClean
    %assign %?clear %?totalArgsSize-%?outs-procClean(%?procName)
    ; if the proc got more data the usual clean it
    %if %?clear>0
        add rsp,%?clear
    %endif

%endmacro

; defines the end of a proc
; endproc
%macro endproc 0
    %[procName]exit:
    %if locals(procName)!=0
        add rsp, locals(procName)
    %endif
    %if heldSize(procName)
        pop held(procName)
    %endif
    %assign __procClean_%[procName] __macro_max(args(procName) - outs(procName),0)
    pop rbp
    ret procClean(procName)
    %pop
    %define inProc 0
%endmacro


; return's values from a proc
; return(out[])
%macro return 0-*
    %assign %?args __macro_max(args(procName),outs(procName))+8

    %assign %?stackcount 0
    %assign %?currentOut 0
    %rep %0
        %if %?stackcount==0
            %assign %?currentOut %?currentOut+1
            %xdefine %?o_%[%?currentOut] %1
        %else
            %xdefine %?o_%[%?currentOut] %?o_%[%?currentOut]%+:%+%1
        %endif
        findInToken %1,"("
        %assign %?stackcount %?stackcount+__1
        findInToken %1,"["
        %assign %?stackcount %?stackcount+__1

        findInToken %1,"]"
        %assign %?stackcount %?stackcount-__1   
        findInToken %1,")"
        %assign %?stackcount %?stackcount-__1
        %rotate 1
    %endrep

    
    %assign %?outc %?currentOut
    %assign %?currentOut 1
    %assign %?out 0
    %rep %?outc
        %ifnum %?o_%[%?currentOut]
            %assign forceMov 1
            mov [rbp+%eval(%?args-%?out*8)],%?o_%[%?currentOut],8
            %assign forceMov 0
        %else
            eval %?o_%[%?currentOut]
            %assign forceMov 1
            mov [rbp+%eval(%?args-%?out*8)],__1,8
            %assign forceMov 0
            endEval
        %endif
        %assign %?out %?out+1
        %assign %?currentOut %?currentOut+1
    %endrep
    jmp %[procName]exit
    resetOld
%endmacro


%assign inCall 0
%assign nCall 0

%macro ocall 1
    %if inCall
        call %1
    %else
        %assign nCall 1
        call %1
    %endif
%endmacro

%macro call 1-*
    %if nCall
        call %1
        %assign nCall 0
        %exitmacro
    %endif

    %xdefine %?func %1
    %rotate 1
    %rep %0-1
        %xdefine %?func %?func %+ : %+ %1
        %rotate 1
    %endrep

    %assign inCall 1

    findInToken %?func,(
    %assign %?argsIndex __1
    subToken %?func,0,%?argsIndex
    %xdefine %?name __1
    subToken %?func,%eval(%?argsIndex+1),-2
    %xdefine %?args __1
    %assign %?useArgs 0

    %if !isEmpty(%?args)
        eval %?args,tbp,1
        %push
        splitArrayToTokens [__1]
        %if %$__0 != 0
            %assign %?useArgs 1
            %xdefine %?arglist %$__1
            %assign %?i 2
            %rep %$__0-1
            %xdefine %?arglist %?arglist%+,%+ %[%$__ %+ %?i]
                %assign %?i %?i+1
            %endrep
        %endif
        %pop
    %endif
    
    %assign %?useOuts 0
    %if outs(%?name)>0
        %assign %?useOuts 1
        %xdefine %?outslist rax
        %rep outs(%?name)/8 -1
            %xdefine %?outslist %+ , %+ rax
        %endrep
    %endif
    
    %if %?useArgs
        %if %?useOuts
            callp %?name,%?arglist,%?outslist
        %else
            callp %?name,%?arglist
        %endif
    %elif %?useOuts
        callp %?name,%?outslist
    %else
        callp %?name
    %endif

    endEval
    %assign inCall 0
%endmacro