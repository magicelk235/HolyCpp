%macro setBlockType 1
    %xdefine %$blockType %1
%endmacro

%macro if 1
    %push 
    setBlockType "if"
    %$ifcheck:
    %assign %$blockCount 0
    eval %1
    cmp qword [addr(__1)],false
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
    cmp qword [addr(__1)],false
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
            jmp %$end:
        %elifidn %$blockType,"dowhile"
            eval %$expression
            cmp qword [addr(__1)],false
            jne %$check
        %endif
        %$end:
    %pop 
%endmacro

%macro while 1
    %push
    setBlockType "while"
    %assign %$blockCount 0
    %$check:
    eval %1
    cmp qword [addr(__1)],false
    je %$exit
%endmacro

%macro dowhile 1
    %push
    setBlockType "dowhile"
    %assign %$blockCount 0
    %xdefine %$expression %1
    %$check:
%endmacro