%macro setBlockType 1
    %xdefine %$blockType %1
%endmacro

%macro if 1
    %push
    setBlockType "if"
    %$ifcheck:
    %assign %$blockCount 0
    eval %1
    mov r15,__1
    endEval
    cmp r15,false
    je %$next%[%$blockCount]
%endmacro

%macro else 0
    jmp %$end
    %$next%[%$blockCount]:
    %assign %$blockCount %$blockCount+1
%endmacro

%macro elif 1
    else
    eval %1
    mov r15,__1
    endEval
    cmp r15,false
    je %$next%[%$blockCount]
%endmacro 

%macro loop 1
    %push
    setBlockType "loop"
    %assign %$blockCount 0
    push r14
    eval %1
    mov r14,__1
    endEval
    %$check:
    cmp r14,0
    je %$end
%endmacro

%macro break 0
    jmp %$end
%endmacro

%macro continue 0
    jmp %$check
%endmacro

%macro end 0
    %ifidn %$blockType,"proc"
        endp
    %elifidn %$blockType,"loop"
        dec r14
        jmp %$check
        %$end:
        pop r14
        %pop
    %else
        %ifidn %$blockType,"while"
            jmp %$check
        %elifidn %$blockType,"if"
            %$next%[%$blockCount]:
            jmp %$end
        %elifidn %$blockType,"dowhile"
            eval %$expression
            mov r15,__1
            endEval
            cmp r15,false
            jne %$check
        %endif
        %$end:
        %pop
    %endif
%endmacro

%macro while 1
    %push
    setBlockType "while"
    %assign %$blockCount 0
    %$check:
    eval %1
    mov r15,__1
    endEval
    cmp r15,false
    je %$end
%endmacro

%macro dowhile 1
    %push
    setBlockType "dowhile"
    %assign %$blockCount 0
    %xdefine %$expression %1
    %$check:
%endmacro

%macro func 1
    findInToken %1,>
    %if __1 != -1
        %assign %%startOutputIndex __1+1
        subToken %1,%%startOutputIndex
        %assign %%outs __1
        subToken %1,0,%%startOutputIndex
        %xdefine %%func __1
    %else
        %xdefine %%func %1
        %assign %%outs 0
    %endif

    findPare %1,(,)
    %assign %%startArgsIndex __1
    %assign %%endIndex __2+1
    getLOperand %%func,%%startArgsIndex,1
    
    %xdefine %%name __1
    %assign %%startIndex __3

    proc %%name,%%outs
    %push
    subToken %%func,%%startArgsIndex,%%endIndex
    %xdefine %%args __1
    %assign %%i 1
    splitArrayToTokens %%args

    %rep %$__0
        ; build %$__i, scope=arg
        new arg %[%$__ %+ %%i]
        %assign %%i %%i+1
    %endrep
    %pop
    %assign __procClean_%[%%name] max(args(%%name) - outs(%%name),0)
%endmacro

%assign inCall 0

%macro ocall 1
    %if inCall
        call %1
    %else
        call %1,0
    %endif
%endmacro

%macro call 1-2
    %if %0==2
        call %1
        %exitmacro
    %endif
    %assign inCall 1

    findInToken %1,(
    %assign %%argsIndex __1
    subToken %1,0,%%argsIndex
    %xdefine %%name __1
    subToken %1,%%argsIndex
    %xdefine %%args __1
    %assign %%useArgs 0

    %if !isEmpty(%%args)
        eval %%args,tbp
        %push
        splitArrayToTokens [__1]
        %if %$__0 != 0
            %assign %%useArgs 1
            %xdefine %%arglist %$__1
            %assign %%i 2
            %rep %$__0-1
            %xdefine %%arglist %%arglist%+,%+ %[%$__ %+ %%i]
                %assign %%i %%i+1
            %endrep
        %endif
        %pop
    %endif
    
    %assign %%useOuts 0
    %if outs(%%name)>0
        %assign %%useOuts 1
        %xdefine %%outslist rax
        %rep outs(%%name)/8 -1
            %xdefine %%outslist %+ , %+ rax
        %endrep
    %endif
    
    %if %%useArgs
        %if %%useOuts
            callp %%name,%%arglist,%%outslist
        %else
            callp %%name,%%arglist
        %endif
    %elif %%useOuts
        callp %%name,%%outslist
    %else
        callp %%name
    %endif

    endEval
    %assign inCall 0
%endmacro