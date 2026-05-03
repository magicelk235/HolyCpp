; getInputType(tok1, tok2, ...)
; Returns type in __1: int, unint, float
; Refs override const-derived types, but not other ref types
%macro getInputType 1-*
    %xdefine %%type int

    %rep %0
        isTokenFloat %1
        %if __1
            ; float const
            %if %%fromConst
                %xdefine %%type float
            %endif
        %elif isRef(%1)
            removeIndex %1
            retm type(__1)
        %endif
        %rotate 1
    %endrep

    retm %%type
%endmacro

%macro useOperator2 4
    getInputType %{2:-1}
    %xdefine %%type __1
    %if isProc(__%[%%type].%1)
        callp __%[%%type].%1,%2,%3,%4
    %else
        __%[%%type].%1 %2,%3,%4
    %endif
%endmacro

%macro useOperator1 3
    getInputType %2
    %xdefine %%type __1
    %if isProc(__%%type.%1)
        callp __%%type.%1,%2,%3
    %else
        __%%type.%1,%2,%3
    %endif
%endmacro

; 3-arg operators (binary)
%macro .add 3
    useOperator2 add,%{1:-1}
%endmacro

%macro .sub 3
    useOperator2 sub,%{1:-1}
%endmacro

%macro .mul 3
    useOperator2 mul,%{1:-1}
%endmacro

%macro .div 3
    useOperator2 div,%{1:-1}
%endmacro

%macro .mod 3
    useOperator2 mod,%{1:-1}
%endmacro

%macro .pow 3
    useOperator2 pow,%{1:-1}
%endmacro

%macro .and 3
    useOperator2 and,%{1:-1}
%endmacro

%macro .or 3
    useOperator2 or,%{1:-1}
%endmacro

%macro .xor 3
    useOperator2 xor,%{1:-1}
%endmacro

%macro .band 3
    useOperator2 band,%{1:-1}
%endmacro

%macro .bor 3
    useOperator2 bor,%{1:-1}
%endmacro

%macro .bxor 3
    useOperator2 bxor,%{1:-1}
%endmacro

%macro .cmp 3
    useOperator2 cmp,%{1:-1}
%endmacro

%macro .equ 3
    useOperator2 equ,%{1:-1}
%endmacro

%macro .nequ 3
    useOperator2 nequ,%{1:-1}
%endmacro

%macro .high 3
    useOperator2 high,%{1:-1}
%endmacro

%macro .low 3
    useOperator2 low,%{1:-1}
%endmacro

%macro .hequ 3
    useOperator2 hequ,%{1:-1}
%endmacro

%macro .lequ 3
    useOperator2 lequ,%{1:-1}
%endmacro

%macro .shl 3
    useOperator2 shl,%{1:-1}
%endmacro

%macro .shr 3
    useOperator2 shr,%{1:-1}
%endmacro

; 2-arg operators (unary)
%macro .bnot 2
    useOperator1 bnot,%{1:-1}
%endmacro

%macro .neg 2
    useOperator1 neg,%{1:-1}
%endmacro

%macro .inc 2
    useOperator1 inc,%{1:-1}
%endmacro

%macro .dec 2
    useOperator1 dec,%{1:-1}
%endmacro

%macro .not 2
    useOperator1 not,%{1:-1}
%endmacro
