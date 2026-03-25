%macro setBlockType 1
    %xdefine %$blockType %1
%endmacro

%macro if 1
    %push 
    setBlockType "if"
    %$ifcheck:
    %assign %$blockCount 0
    eval rax,%1
    cmp rax,false
    je %$next%[%$blockCount]
%endmacro

%macro else 0
    jmp %$end
    %$next%[%$blockCount]:
    %assign %$blockCount %$blockCount+1
%endmacro

%macro elif 1
    else
    eval rax,%1
    cmp rax,false
    je %$next%[%$blockCount]
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
    %else
        %ifidn %$blockType,"while"
            jmp %$check
        %elifidn %$blockType,"if"
            %$next%[%$blockCount]:
            jmp %$end
        %elifidn %$blockType,"dowhile"
            eval rax,%$expression
            cmp rax,false
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
    eval rax,%1
    cmp rax,false
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
    getLOperand %%func,%%startArgsIndex
    %xdefine %%name __2
    %assign %%startIndex __3

    proc %%name,%%outs
    %push
    subToken %%func,%%startArgsIndex,%%endIndex
    %xdefine %%args __1
    %assign %%i 1
    splitListToTokens %%args

    %rep %$__0
        ; build %$__i, scope=arg
        new arg %[%$__ %+ %%i]
        %assign %%i %%i+1
    %endrep
    %pop

%endmacro