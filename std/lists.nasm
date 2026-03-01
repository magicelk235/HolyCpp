; eg: x[5] -> __1=x,__2=5
; splitIndex(token)
%macro splitIndex 1
    findInToken %1,[
    %assign %%startIndex __1

    subToken %1,%%startIndex+1,-2
    %xdefine %%index __1

    subToken %1,0,%%startIndex
    retm __1,%%index
%endmacro

; generate instructions to calculate the offset of the index at a given index and returns the pointer and the list ref
; getIndexOffset(listToken,Token)
%macro getIndexOffset 2

    splitIndex %1
    %xdefine %%ref __1
    %xdefine %%index __2


    %if ptr(%%ref)
        resr %2
        lea r,%%ref
        %xdefine %%base r
    %else
        %xdefine %%base addr(%%ref)
    %endif

    %ifnum %%index
        retm [%%base + %eval(size(%%ref)*%%index + listSizeOffset)],size(%%ref)
    %else
        resr %2,r
        lsd %%index,r
        movSize r,__1,8,__2
        imul r,size(%%ref)
        retm [%%base + r + listSizeOffset],size(%%ref)
    %endif
%endmacro

; isTokenList(Token)
%macro isTokenList 1
    findInToken %1,[
    retm %eval(__1!=-1&&__1!=0)
%endmacro

; dest,ref
%macro blen 2
    lea %2,%1
    mov %1,[__1]
%endmacro

; dest,ref
%macro len 2
    blen %1,%2
    div %1,size(%2),%1
%endmacro