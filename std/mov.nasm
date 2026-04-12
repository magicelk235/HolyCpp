;lsd
%macro lsd 2
    ; const number check
    %if isTokenNum(%1)
        TokenToNum %1
        %assign %%const __1
        setFloat %2,__2
        %if !(isNumInSize(%%const,4) || isReg(%2))||isXmmReg(%2)
            resr %2
            omov r,%%const
            sizeByToken %2
            retm r,min(__1,8)
            %exitmacro
        %endif

        sizeByToken %2
        retm %%const,__1
        %exitmacro
    %endif

    ; register check
    %if isReg(%1)
        retm %1,size(%1)
        %exitmacro
    %endif


    isPtr %1
    %if __1
        %assign %%at __2
        replaceToken %1,@,""
        %xdefine %%ref __1
        lra %%ref,%2,"",%%at
        retm [__1],size(%%ref)
        %exitmacro
    %endif

    ; checks for direct ref
    %if isDirectRef(%1)
        lra %1,%2,"",0
        retm [__1],size(%1)
        %exitmacro
    %endif



    ; checks for memory
    isDirectMemory %1
    %if __1
        retm %1,size(%2)
        %exitmacro
    %endif
    retm emptyToken,emptyToken
%endmacro

; lxd(token1,token2)
%macro lxd 2

    lsd %1,%2
    %ifidn __2,emptyToken
    %else
        retm __1,__2
        %exitmacro
    %endif

    ; checks for arrays
    %if isTokenIndex(%1)
        getIndexOffset %1,%2
        %exitmacro
    %endif
%endmacro

%macro isMemory 1
    isDirectMemory %1
    %if __1
        retm 1
        %exitmacro
    %endif

    isPtr %1
    %if __1
        retm 1
        %exitmacro
    %endif

    retm isRef(%1)
%endmacro

%macro resetOld 0
    %define oldAutomovDest 0
    %define oldAutomovSrc 0
    %define oldMovDest 0
    %define oldMovSrc 0
%endmacro



; moves that works with any given size to any given size
; movSize(dest,src,ds,ss)
%macro movSize 4
    %if %3 = 16 && %4 = 16 ; checks if both dest and src are xmm
        movdqu %1, %2
    %elif %3 = 16
        %if %4 = 8
            movq %1, %2
        %elif %4 = 4
            movd %1, %2
        %endif
    %elif %4 = 16
        %if %3 = 8
            movq %1, %2
        %elif %3 = 4
            movd %1, %2
        %endif
    %elif %3 >= %4
        %if %3 == %4
            omov sizename(%3) %1, sizename(%3) %2
        %elif isReg(%1)
            %if %4 != 4
                movsx sizename(%3) %1, sizename(%4) %2
            %else
                movsxd qword %1, dword %2
            %endif
        %else
            resr s:%3,%2
            %if %3 != 4
                movsx r, sizename(%4) %2
            %else
                movsxd r, dword %2
            %endif
            omov %1,r
        %endif
    %else
        %if isReg(%2)
            %xdefine %%group group(%2)
            omov %1, reg(%3, %%group)
        %else
            omov %1, %2
        %endif
    %endif
%endmacro

; automov(dest,src,?ds,?ss)
%macro automov 2-4
    %xdefine %%0 %0
    lxd %1,%2
    %xdefine %%dest __1

    %if %%0 >= 3
        %xdefine %%ds %3
    %else
        %xdefine %%ds __2
    %endif

    lxd %2,%1
    %xdefine %%src __1

    %if %%0 == 4
        %xdefine %%ss %4
    %elifnum __2
        %xdefine %%ss __2
    %else
        %xdefine %%ss %%ds
    %endif

    %if !forceMov
        %ifidn %%dest,%%src
            %exitmacro
        %elif %isidn(%%dest,oldAutomovDest) && %isidn(%%src,oldAutomovSrc)
            %exitmacro
        %elif %isidn(%%src,oldAutomovDest) && %isidn(%%dest,oldAutomovSrc)
            %exitmacro
        %endif
    %endif

    %xdefine oldAutomovDest %%dest
    %xdefine oldAutomovSrc %%src
    movSize %%dest,%%src,%%ds,%%ss
    %if isXmmReg(%2)
        setFloat %1,1
    %endif
%endmacro

%macro doubleMemoryMov 2-4

    isMemory %1
    %xdefine %%is1Memory __1

    isMemory %2
    %xdefine %%is2Memory __1
    %if %%is1Memory && %%is2Memory
        automov rax,%2
        %if %0==2
            automov %1,rax
        %else
            automov %1,rax,%3
        %endif
    %else
        automov %{1:-1}
    %endif
%endmacro


%define inMov 0
%assign forceMov 0

;original mov(dest,src)
%macro omov 2
    %if inMov
        mov %1,%2
    %else
        mov %1,%2,0,0,0
    %endif
%endmacro


; mov(dest,src,?ds,?ss)
%macro mov 2-5
    %if %0==5
        mov %1,%2
        %exitmacro
    %endif
    %if !forceMov
        %ifidn %1,%2
            %exitmacro
        %elif %isidn(oldMovDest,%1) && %isidn(oldMovSrc,%2)
            %exitmacro
        %elif %isidn(oldMovDest,%2) && %isidn(oldMovSrc,%1)
            %exitmacro
        %elifidn addr(%1),addr(%2)
            %exitmacro
        %elifidn group(%1),group(%2)
            %exitmacro
        %endif
    %endif
    %define inMov 1

    tokenCount %2,@
    %if __1 != 0
        %assign %%depth __1-1
        replaceToken %2,@,""
        lea __1,%1,%%depth
        %define inMov 0
        %exitmacro
    %endif

    %if isRef(%1)&&%isstr(%2)
        %xdefine %%str %2

        %strlen %%len %%str
        tokenCount %%str,"\"
        %assign %%realLen %%len-__1
        tokenCount %%str,"\\"
        %assign %%realLen %%realLen+__1

        addrOf %1,rbx,"",0
        omov qword [__1],%%realLen
        %assign __times_%1 %%realLen
        %assign %%special 0
        %assign %%i 1
        %rep %%len
            %substr %%char %%str %%i
            %if %%special
                %if %%char == "n"
                    omov byte [__1 + %eval(%%i-1 + arraySizeOffset)],10
                %elif %%char == "a"
                    omov byte [__1 + %eval(%%i-1 + arraySizeOffset)],7
                %elif %%char == "b"
                    omov byte [__1 + %eval(%%i-1 + arraySizeOffset)],8
                %elif %%char == "v"
                    omov byte [__1 + %eval(%%i-1 + arraySizeOffset)],11
                %elif %%char == "f"
                    omov byte [__1 + %eval(%%i-1 + arraySizeOffset)],12
                %elif %%char == "r"
                    omov byte [__1 + %eval(%%i-1 + arraySizeOffset)],13
                %elif %%char == "\"
                    omov byte [__1 + %eval(%%i-1 + arraySizeOffset)],92
                %elif %%char == "0"
                    omov byte [__1 + %eval(%%i-1 + arraySizeOffset)],0
                %endif
                %assign %%special 0
            %else
                %if %%char == "\"
                    %assign %%special 1
                %else
                    omov byte [__1 + %eval(%%i-1 + arraySizeOffset)],%%char
                %endif
            %endif
            %assign %%i %%i+1
        %endrep
        omov byte [__1 + %eval(%%i-1 + arraySizeOffset)],0
        %define inMov 0
        %exitmacro
    %endif

    isTokenArray %2
    %if __1
        %push
        splitArrayToTokens %2
        addrOf %1,rax,"",0
        %xdefine %%addr __1
        %assign %%i 1
        %rep %$__0
            doubleMemoryMov [%%addr+%eval(size(%1)*(%%i-1)+ arraySizeOffset)],%$__%[%%i],size(%1)
            %assign %%i %%i+1
        %endrep
        %pop
        %define inMov 0
        %exitmacro
    %endif
    doubleMemoryMov %{1:-1}
    %define inMov 0
%endmacro

%macro sizeByToken 1
    ; register
    %if isReg(%1)
        retm size(%1)
    ; ref
    %else
        splitIndex %1
        retm size(__1)
    %endif
%endmacro
