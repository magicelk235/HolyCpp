; makes a new ref that store size,addr,depth,type,signed,shape...
; newRef(name, addr, type, depth, shape...)
%macro newRef 5-*
    %xdefine __%1@ref@addr %2
    %xdefine __%1@ref@type %3
    %xdefine __%1@size classSize(%3)
    %assign __%1@ref@depth %4
    %assign __ref@ref@%1 1
    %xdefine refName %1

    %assign __%1@ref@totalSize 8*(%4>0)+size(%1)*(%4<=0) ; 8 byte pointer or real size
    newList __%1@ref@shape
    %rotate 4
    %rep %0-4
        %assign __%[refName]@ref@totalSize totalSize(refName)*%1
        listpush __%[refName]@ref@shape, %1
        %rotate 1
    %endrep

    %ifnmacro %[refName]
        %macro %[refName] 1-*
            set %?%{1:-1}
        %endmacro
    %endif

    %rep depth(%[refName])
        %xdefine refName @%+refName
        %ifnmacro %[refName]
            %macro %[refName] 1-*
            set %?%{1:-1}
            %endmacro
        %endif
    %endrep
%endmacro

%define totalSize(name) __ %+ name %+ @ref@totalSize
%define type(name) __ %+ name %+ @ref@type
%define depth(name) __ %+ name %+ @ref@depth
%define shape(name) __ %+ name %+ @ref@shape
%define addr(name) __ %+ name %+ @ref@addr
%define signed(name) %isidn(classSigned(%[type(name)]),1)
%define isRef(x) %isnum(__ref@ref@%+x)
%define isDirectRef(x) %isidn(__ref@ref@%+x, 1)

; search for [ at start
; isDirectMemory(token)
%macro isDirectMemory 1
    subToken %1,0,1
    %ifnidn __1,[
        retm 0
        %exitmacro
    %endif
    findInToken %1,:
    retm %eval(__1==-1)
%endmacro

; load ref's address
; lra(ref,ignored,use,depthOffset)
%macro lra 4
    retm 0
    %if isDirectRef(%1)
        %assign %?depth depth(%1)-%4
        %if %?depth>0
            %if isReg(%3)
                %xdefine r reg(8,%[group(%3)])
            %else
                resr %2
            %endif
            omov r,[addr(%1)]
            %rep %?depth-1
                omov qword r,[r]
            %endrep
            retm r
        %else
            retm addr(%1)
        %endif
    %endif
%endmacro

;  a ref or arrays address or direct mem
; addrOf(ref,ignored,used,depthOffset)
%macro addrOf 4
    isDirectMemory %1
    %if __1
        subToken %1,1,-2
    %else
        lra %1,%2,%3,%4
        %ifidn __1,0
            getIndexOffset %1,%2,%3,%4
        %endif
    %endif
%endmacro

%assign inlea 0

%macro olea 2
    %if inlea
        lea %1,%2
    %else
        lea %1,%2,0,0
    %endif
%endmacro

; ref/array,dest,depth
%macro lea 2-4
    %if %0==4
        lea %1,%2
        %exitmacro
    %endif

    %assign inlea 1
    %if %0==2
        %assign %?depthOffset 0
    %else
        %assign %?depthOffset %3
    %endif
    addrOf %1,"",%2,%?depthOffset
    %if isReg(%2)
        %ifnidn %2,__1
            lea %2,[__1]
        %endif
    %elif isRef(%2)
        %xdefine %?addr __1
        resr %?addr
        lea r,[%?addr]
        mov %2,r
    %else
        lea %2,[%1]
    %endif
    resetOld
    %assign inlea 0
%endmacro

; allocbss(totalSize)
%macro allocbss 1
    section .bss
    %%l resb %1
    section .text
    retm %%l
%endmacro

; allocsection(totalSize,data,section)
%macro allocsection 3
    section %3
    %ifstr %2
        parseStr %2
        %xdefine %?str __1
        %%l:
        %assign %?i 0
        %rep listlen(%?str)
            db listIndex(%?str,%?i)
            %assign %?i %?i+1
        %endrep
    %else
        %%l:
        splitArrayToElements %2
        %xdefine %?elements __1
        %assign %?i 0
        %rep listlen(%?elements)
            dq listIndex(%?elements,%?i)
            %assign %?i %?i+1
        %endrep
    %endif
    section .text
    retm %[%%l]
%endmacro

; allocdata(totalSize,data)
%macro allocdata 2
    allocsection %1,%2,.data
%endmacro

; allocrdata(totalSize,data)
%macro allocrdata 2
    allocsection %1,%2,.rdata
%endmacro

; allocglobal(name, type, depth, shape, data)
%macro allocglobal 5
    listToTuple %4
    newRef %1,0,%2,%3,__1

    isNumber %5
    %assign %%validdata __1
    isTokenArray %5
    %assign %%validdata %%validdata || __1

    %if %%validdata || %isstr(%5)
        allocdata totalSize(%1),%5
        %xdefine __%[%1]@ref@addr __1
    %else
        allocbss totalSize(%1)
        %xdefine __%[%1]@ref@addr __1
    %endif
%endmacro

; allocconst(name, type, depth, shape, data)
%macro allocconst 5
    listToTuple %4
    newRef %1,0,%2,%3,__1

    allocrdata totalSize(%1),%5
    %xdefine __%[%1]@ref@addr __1
%endmacro

; getScope(expression)
; returns scope (token), cleaned expression
%macro getScope 1
    %xdefine %?expr %1
    findInToken %?expr,"global "
    %if __1 != -1
        replaceToken %?expr,"global ",""
        retm global,__1
        %exitmacro
    %endif
    findInToken %?expr,"local "
    %if __1 != -1
        replaceToken %?expr,"local ",""
        retm local,__1
        %exitmacro
    %endif
    findInToken %?expr,"tbp "
    %if __1 != -1
        replaceToken %?expr,"tbp ",""
        retm tbp,__1
        %exitmacro
    %endif
    findInToken %?expr,"tsp "
    %if __1 != -1
        replaceToken %?expr,"tsp ",""
        retm tsp,__1
        %exitmacro
    %endif
    findInToken %?expr,"const "
    %if __1 != -1
        replaceToken %?expr,"const ",""
        retm const,__1
        %exitmacro
    %endif
    findInToken %?expr,"arg "
    %if __1 != -1
        replaceToken %?expr,"arg ",""
        retm arg,__1
        %exitmacro
    %endif
    findInToken %?expr,"static "
    %if __1 != -1
        replaceToken %?expr,"static ",""
        retm static,__1
        %exitmacro
    %endif
    %if inProc
        retm local,%?expr
    %elif inClass
        retm class,%?expr
    %else
        retm global,%?expr
    %endif
%endmacro

; new(type,name)
%macro new 1-*
    joinBracketSplit %{1:-1}

    %xdefine %?type listIndex(__1,0)
    %xdefine %?expression listIndex(__1,1)

    %xdefine %?data emptyToken
    findInToken %?expression,= ; split start data
    %if __1!=-1
        %assign %?startDataIndex __1+1
        subToken %?expression,%?startDataIndex
        %xdefine %?data __1
        subToken %?expression,0,%eval(%?startDataIndex-1)
        %xdefine %?expression __1
    %endif

    getScope %?expression
    %xdefine %?scope __1
    %xdefine %?expression __2

    ; search for [] if is an array
    splitIndex %?expression

    %if isEmpty(listIndex(__2,0))
        %xdefine %?expression __1
    %endif

    %if %isnidn(__1,0) && !isEmpty(listIndex(__2,0))
        %xdefine %?expression __1
        %xdefine %?shape __2
    %else
        newList %?shape
        isTokenArray %?data
        %if __1
            getArrayShape %?data
            %xdefine %?shape __1
        %elifstr %?data
            listsetindex %?shape,0,%eval(%strlen(%?data)+1)
        %else
            listpush %?shape,1
        %endif
    %endif

    ; pointer depth searches for @
    tokenCount %?expression,@
    %assign %?depth __1

    replaceToken %?expression,@,""
    %xdefine %?expression __1

    ; dynamic dispatch to alloc{scope}
    alloc%[%?scope] %?expression,%?type,%?depth,%?shape,%?data
%endmacro

; set
%macro set 1-*
    %xdefine %?data %1
    %rotate 1
    %rep %0-1
        %xdefine %?data %?data %+ : %+ %1
        %rotate 1
    %endrep

    clearSpaces %?data
    %xdefine %?data __1

    findInToken %?data,=
    %if __1!=-1
        %assign %?startDataIndex __1
        subToken %?data,%eval(%?startDataIndex+1)
        %xdefine %?expression __1

        subToken %?data,%eval(%?startDataIndex-1),%?startDataIndex
        %xdefine %?sub __1

        isOperator %str(%?sub)
        %if __1
            subToken %?data,0,%eval(%?startDataIndex-1)
            %xdefine %?expression __1
            %xdefine %?expression (%?expression)%+%?sub%+%?expression
        %else
            subToken %?data,0,%?startDataIndex
            %xdefine %?expression __1
        %endif
        eval %?expression
        mov %?expression,__1
        endEval
    %else
            findInToken %?data,"++"
    %if __1 != -1
        subToken %?data,0,__1
        lxd __1,""
        inc sizename(__2) __1
    %else
        findInToken %?data,"--"
        %if __1 != -1
            subToken %?data,0,__1
            lxd __1,""
            dec sizename(__2) __1
        %endif
    %endif
    %endif
%endmacro