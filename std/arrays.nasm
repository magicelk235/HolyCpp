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

%define listPointer(ref) %eval(times(ref)>1&&depth(ref)>0)

; generate instructions to calculate the offset of the index at a given index and returns the pointer and the array ref
; getIndexOffset(index,Token,usedReg,depthOffset)
%macro getIndexOffset 4

    splitIndex %1
    %xdefine %%ref __1
    %xdefine %%index __2

    %ifidn %%index,#
        %if listPointer(%%ref)
            retm addr(%%ref),8
            %exitmacro
        %else
            lra %%ref,%2,"",0
            retm __1,8
            %exitmacro
        %endif
    %endif

    %if listPointer(%%ref)
        %xdefine %%base addr(%%ref)
        %assign %%size 8
    %else
        lra %%ref,%%index,"",0
        %xdefine %%base __1
        %assign %%size size(%%ref)
    %endif
        
    
    %ifnum %%index
        %assign %%useR 0
        %xdefine %%offset %%base+%eval(%%size*%%index+arraySizeOffset)
    %else
        %assign %%useR 1
        %if isReg(%3)
            %xdefine r reg(8,%[group(%3)])
        %else
            resr %2,%%base
        %endif
        lsd %%index,r
        %xdefine %%indexPtr __1
        %xdefine %%indexSize __2
        isInputSigned %%index
        movSize r,%%indexPtr,8,%%indexSize,__1
        %xdefine %%offset %%base+%[r]*%%size+arraySizeOffset
    %endif

    %if depth(%%ref)-%3>0
        %if %%useR
            omov r,[%%offset]
        %else
            %if isReg(%3)
                %xdefine r reg(8,%[group(%3)])
            %else
                resr %2,%%base
            %endif
            omov r,[%%offset]
        %endif
        %rep depth(%%ref)-%3-1
            omov r,[r]
        %endrep
        retm r,size(%%ref)
    %else
        retm %%offset,size(%%ref)
    %endif
%endmacro

%define isTokenIndex(x) isRef(x)&&!isDirectRef(x)

%macro isTokenArray 1
    findInToken %1,:
    retm %eval(__1!=-1)
%endmacro

;[1:2:3:4] -> %$__1 = 1,%$__2 = 2, %$__3 = 3....
; splitArrayToTokens(arrayConst) -> tokensarray
%macro splitArrayToTokens 1
    subToken %1,1,-2

    %xdefine %%array __1

    %if isEmpty(%%array)
        %assign %$__0 0
        %exitmacro
    %endif

    findInToken %%array,:
    %if __1 == -1
        retms %%array
        %exitmacro
    %endif

    %rep 100000
        findInToken %%array,:
        %if __1 == -1
            %xdefine %%tokensArray %%tokensArray%+,%+%%array
            %exitrep
        %endif

        %assign %%index __1
        subToken %%array,0,%%index

        %ifdef %%tokensArray
            %xdefine %%tokensArray %%tokensArray%+,%+__1
        %else
            %xdefine %%tokensArray __1
        %endif

        subToken %%array,%eval(%%index+1),-1
        %xdefine %%array __1
    %endrep
    retms %%tokensArray
%endmacro