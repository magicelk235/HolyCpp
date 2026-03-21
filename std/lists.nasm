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
; getIndexOffset(list,Token)
%macro getIndexOffset 2

    splitIndex %1
    %xdefine %%ref __1
    %xdefine %%index __2

    %ifidn %%index,#
        lsd %%ref,%2
        retm __1,8
        %exitmacro
    %endif

    lra %%ref,%%index
    %xdefine %%base __1

    %ifnum %%index
        retm [%%base + %eval(size(%%ref)*%%index + listSizeOffset)],size(%%ref)
    %else
        resr %2,%%base
        lsd %%index,r
        movSize r,__1,8,__2
        imul r,size(%%ref)
        retm [%%base + r + listSizeOffset],size(%%ref)
    %endif
%endmacro

%define isTokenIndex(x) isRef(x)&&!isDirectRef(x)

%macro isTokenList 1
    findInToken %1,:
    retm %eval(__1!=-1)
%endmacro

;[1:2:3:4] -> __1 = 1,__2 = 2, __3 = 3....
; splitListToTokens(listConst) -> tokenslist
%macro splitListToTokens 1
    subToken %1,1,-2

    %xdefine %%list __1
    
    %rep 100000
        findInToken %%list,:
        %if __1 == -1
            %xdefine %%tokensList %%tokensList%+,%+%%list
            %exitrep
        %endif

        %assign %%index __1
        subToken %%list,0,%%index

        %ifdef %%tokensList
            %xdefine %%tokensList %%tokensList%+,%+__1
        %else
            %xdefine %%tokensList __1
        %endif

        subToken %%list,%eval(%%index+1),-1
        %xdefine %%list __1
    %endrep
    retm s:,%%tokensList
%endmacro