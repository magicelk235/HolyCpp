%macro removeIndex 1
    findInToken %1,[
    %if __1!=-1
        subToken %1,0,__1
    %else
        retm %1
    %endif
%endmacro

; splitIndex(token) -> ref, indexes
%macro splitIndex 1
    findInToken %1,[
    %assign %?start __1

    subToken %1,0,%?start
    %xdefine %?ref __1

    ; extract inner: "5][3][2" from "[5][3][2]"
    subToken %1,%?start+1,-2

    splitToken __1,][
    retm %?ref,%[__1]
%endmacro

%define listPointer(ref) %eval(listIndex(shape(ref),0)>1&&depth(ref)>0)

; generate instructions to calculate the offset of the index at a given index and returns the pointer and the array ref
; getIndexOffset(index,ignored,usedReg,depthOffset)
%macro getIndexOffset 4

    splitIndex %1
    %xdefine %?ref __1
    %xdefine %?indexes __2

    %if listPointer(%?ref)
        %xdefine %?base addr(%?ref)
        %assign %?size 8
    %else
        lra %?ref,%?index,"",0
        %xdefine %?base __1
        %assign %?size size(%?ref)
    %endif
    
    %assign %?usedReg 0
    %assign %?usedR 0
    %assign %?i 1
    %rep listlen(%?indexes)
        %xdefine %?scaler 1
        %assign %?j %?i
        %rep listlen(shape(%?ref))-%?i
            %xdefine %?scaler %?scaler*listIndex(shape(%?ref),%?j)
            %assign %?j+1
        %endrep

        %xdefine %?index listIndex(%?indexes,%eval(%?i-1))

        %ifnum %?index
            %xdefine %?base %?base+%eval(%?size*%?index*%?scaler)
        %else
            %if isReg(%3)&&!%?usedReg
                %xdefine r reg(8,%[group(%3)])
                %assign %?usedReg 1
            %else
                resr %2,%?base
            %endif
            lsd %?index,r
            %xdefine %?indexPtr __1
            %xdefine %?indexSize __2
            isInputSigned %?index
            movSize r,%?indexPtr,8,%?indexSize,__1
            %if !isPow2(%?size*%?scaler)
                imul r,%?size*%?scaler
                olea r,[%?base+%[r]]
            %elif %?size*%?scaler>8
                shl r,ilog2(%?size*%?scaler)
                olea r,[%?base+%[r]]
            %else
                olea r,[%?base+%[r]*%?size*%?scaler]
            %endif
            %xdefine %?base r
        %endif
        %assign %?i %?i+1
    %endrep

    %if depth(%?ref)-%3>0
        %if %?usedR
            omov r,[%?base]
        %else
            %if isReg(%3)
                %xdefine r reg(8,%[group(%3)])
            %else
                resr %2,%?base
            %endif
            omov r,[%?base]
        %endif
        %rep depth(%?ref)-%3-1
            omov r,[r]
        %endrep
        retm r,size(%?ref)
    %else
        retm %?base,size(%?ref)
    %endif
%endmacro

%define isTokenIndex(x) isRef(x)&&!isDirectRef(x)

%macro isTokenArray 1
    findInToken %1,:
    retm %eval(__1!=-1)
%endmacro

; splitArrayToElements(arrayConst) -> elements
%macro splitArrayToElements 1
    replaceToken %1,[,""
    replaceToken __1,],""
    splitToken __1,:
    retm __1
%endmacro



%macro countElements 1
    %assign %?count 1
    %assign %?stack 0

    %assign %?stringMode 0
    %assign %?stringType 0

    toStr %1
    %define %?array __1
    %substr %?array %?array 2,%eval(%strlen(%?array)-1)
    
    %assign %?i 1

    %rep %strlen(%?array)
        %substr %?sub %?array %?i,1
        updateStringMode %?sub,%?stringMode,%?stringType
        %assign %?stringMode __1
        %assign %?stringType __2
        %if !%?stringMode
            %ifidn %?sub,"["
                %assign %?stack %?stack+1
            %elifidn %?sub,"]"
                %assign %?stack %?stack-1
            %elifidn %?sub,"("
                %assign %?stack %?stack+1
            %elifidn %?sub,")"
                %assign %?stack %?stack-1
            %endif
            %if %?stack == 0
                %ifidn %?sub,":"
                    %assign %?count %?count+1
                %endif
            %endif
        %endif
        %assign %?i %?i+1
    %endrep
    retm %?count
%endmacro

%macro getArrayFirstElement 1
    %assign %?stack 0

    %assign %?stringMode 0
    %assign %?stringType 0

    toStr %1
    %define %?array __1
    %substr %?array %?array 2,%eval(%strlen(%?array)-1)
    %xdefine %?element %?array
    %assign %?i 1

    %rep %strlen(%?array)
        %substr %?sub %?array %?i,1
        updateStringMode %?sub,%?stringMode,%?stringType
        %assign %?stringMode __1
        %assign %?stringType __2
        %if !%?stringMode
            %ifidn %?sub,"["
                %assign %?stack %?stack+1
            %elifidn %?sub,"]"
                %assign %?stack %?stack-1
            %elifidn %?sub,"("
                %assign %?stack %?stack+1
            %elifidn %?sub,")"
                %assign %?stack %?stack-1
            %endif
            %if %?stack == 0
                %ifidn %?sub,":"
                    %substr %?element %?array,0,%?i-1
                    %exitrep
                %endif
            %endif
        %endif
        %assign %?i %?i+1
    %endrep
    retm %?element
%endmacro

%macro getArrayShape 1
    toStr %1
    %xdefine %?array __1

    ; gets the dim of the array
    %assign %?dim 0
    %assign %?i 1
    %assign %?stringMode 0
    %assign %?stringType 0
    %rep 100000
        %substr %?sub %?array %?i,1
        updateStringMode %?sub,%?stringMode,%?stringType
        %assign %?stringMode __1
        %assign %?stringType __2
        %if !%?stringMode
            %ifidn %?sub,"["
                %assign %?dim %?dim+1
            %elif %?sub,"]"
                %exitrep                
            %endif
        %endif
        %assign %?i %?i+1
    %endrep

    newList %?shape
    %rep %?dim
        countElements %?array
        listpush %?shape,__1
        getArrayFirstElement %?array
        %xdefine %?array __1
    %endrep
    retm %?shape
%endmacro