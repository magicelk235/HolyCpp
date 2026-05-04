;lsd
%macro lsd 2
    ; const number check
    isTokenNum %1
    %if __1
        TokenToNum %1
        %assign %?const __1
        %if !(isNumInSize(%?const,4) || isReg(%2))||isXmmReg(%2)
            resr %2
            omov r,%?const
            sizeByToken %2
            retm r,__macro_min(__1,8)
            %exitmacro
        %endif

        sizeByToken %2
        retm %?const,__1
        %exitmacro
    %endif

    ; register check
    %if isReg(%1)
        retm %1,size(%1)
        %exitmacro
    %endif


    isPtr %1
    %if __1
        %assign %?at __2
        replaceToken %1,@,""
        %xdefine %?ref __1
        lra %?ref,%2,"",%?at
        retm [__1],size(%?ref)
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
    %ifnidn __2,emptyToken
        retm __1,__2
        %exitmacro
    %endif

    ; checks for arrays
    %if isTokenIndex(%1)
        getIndexOffset %1,%2,0,0
        retm [__1],__2
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

%macro resetOldAutoMov 0
    %define oldAutomovDest 0
    %define oldAutomovSrc 0
%endmacro

%macro resetOld 0
    resetOldAutoMov
    %define oldMovDest 0
    %define oldMovSrc 0
%endmacro



; moves that works with any given size to any given size
; movSize(dest,src,ds,ss,signed)
%macro movSize 5
    %if %5
        %xdefine %?ext sx
    %else
        %xdefine %?ext zx
    %endif

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
                mov%+%?ext sizename(%3) %1, sizename(%4) %2
            %else
                %if %5
                    movsxd qword %1, dword %2
                %else
                    omov reg(4,%[group(%1)]), dword %2
                %endif
            %endif
        %else
            %if %5
                resr s:%3,%2
                %if %3 != 4
                    mov%+%?ext r, sizename(%4) %2
                %else
                    mov%+%?ext%+d r, dword %2
                %endif
                omov %1,r
            %else
                %if %4 != 4
                    resr s:%3,%2
                    movzx sizename(%3) r, sizename(%4) %2
                    omov %1,r
                %else
                    subToken %1,0,-2
                    omov dword __1+4], 0
                    omov dword %1, dword %2
                %endif
            %endif
        %endif
    %else
        %if isReg(%2)
            %xdefine %?group group(%2)
            omov %1, reg(%3, %?group)
        %else
            omov %1, %2
        %endif
    %endif
%endmacro

; automov(dest,src,?ds,?ss)
%macro automov 2-4
    lxd %1,%2
    %xdefine %?dest __1

    %if %0 >= 3
        %xdefine %?ds %3
    %else
        %xdefine %?ds __2
    %endif

    lxd %2,%1
    %xdefine %?src __1

    %if %0 == 4
        %xdefine %?ss %4
    %elifnum __2
        %if __2==0
            %xdefine %?ss %?ds
        %else
            %xdefine %?ss __2
        %endif
    %else
        %xdefine %?ss %?ds
    %endif

    %if !forceMov
        %ifidn %?dest,%?src
            %exitmacro
        %elif %isidn(%?dest,oldAutomovDest) && %isidn(%?src,oldAutomovSrc)
            %exitmacro
        %elif %isidn(%?src,oldAutomovDest) && %isidn(%?dest,oldAutomovSrc)
            %exitmacro
        %endif
    %endif

    %xdefine oldAutomovDest %?dest
    %xdefine oldAutomovSrc %?src
    isInputSigned %1,%2
    movSize %?dest,%?src,%?ds,%?ss,__1
    %if isXmmReg(%2)
        setFloat %1,1
    %endif
%endmacro

%macro doubleMemoryMov 2-4

    isMemory %1
    %xdefine %?is1Memory __1

    isMemory %2
    %xdefine %?is2Memory __1
    %if %?is1Memory && %?is2Memory
        
        %if %0 == 3
            %assign %?size1 %3
        %else
            sizeByToken %1
            %assign %?size1 __1
        %endif

        %if %0 == 4
            %assign %?size2 %4
        %else
            sizeByToken %2
            %assign %?size2 __1
        %endif
        %if isPow2(%?size1)&&isPow2(%?size2)
            %xdefine %?r reg(__macro_max(%?size1,%?size2),0)
            automov %?r,%2
            resetOldAutoMov
            %if %0==2
                automov %1,%?r
            %else
                automov %1,%?r,%3
            %endif
        %else
            addrOf %1,"","",0
            %xdefine %?dest __1
            addrOf %2,%?dest,"",0
            %xdefine %?src __1
            %assign %?copySize __macro_min(%?size1,%?size2)
            %assign %?offset 0

            %rep %?copySize/16
                movdqu xmm0,[%?src+%?offset]
                movdqu [%?dest+%?offset],xmm0
                %assign %?offset %?offset+16
            %endrep
            %assign %?copySize %?copySize % 16

            %rep %?copySize/8
                omov r8,[%?src+%?offset]
                omov [%?dest+%?offset],r8
                %assign %?offset %?offset+8
            %endrep
            %assign %?copySize %?copySize % 8

            %rep %?copySize/4
                omov r8d,[%?src+%?offset]
                omov [%?dest+%?offset],r8d
                %assign %?offset %?offset+4
            %endrep

            %assign %?copySize %?copySize % 4
            %rep %?copySize/2
                mov r8w,[%?src+%?offset]
                mov [%?dest+%?offset],r8w
                %assign %?offset %?offset+2
            %endrep

            %if %?copySize % 2
                mov r8b,[%?src+%?offset]
                mov [%?dest+%?offset],r8b
            %endif
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
        %assign %?depth __1-1
        replaceToken %2,@,""
        lea __1,%1,%?depth
        %define inMov 0
        %exitmacro
    %endif

    %if isRef(%1)&&%isstr(%2)
        %xdefine %?str %2

        %strlen %?len %?str
        tokenCount %?str,"\"
        %assign %?realLen %?len-__1
        tokenCount %?str,"\\"
        %assign %?realLen %?realLen+__1

        addrOf %1,rbx,"",0
        %assign __times_%1 %?realLen
        %assign %?special 0
        %assign %?i 1
        %rep %?len
            %substr %?char %?str %?i
            %define %?addr __1+%eval(%?i-1)
            %if %?special
                %if %?char == "n"
                    omov byte [%?addr],10
                %elif %?char == "a"
                    omov byte [%?addr],7
                %elif %?char == "b"
                    omov byte [%?addr],8
                %elif %?char == "v"
                    omov byte [%?addr],11
                %elif %?char == "f"
                    omov byte [%?addr],12
                %elif %?char == "r"
                    omov byte [%?addr],13
                %elif %?char == "\"
                    omov byte [%?addr],92
                %elif %?char == "0"
                    omov byte [%?addr],0
                %endif
                %assign %?special 0
            %else
                %if %?char == "\"
                    %assign %?special 1
                %else
                    omov byte [%?addr],%?char
                %endif
            %endif
            %assign %?i %?i+1
        %endrep
        omov byte [%?addr],0
        %define inMov 0
        %exitmacro
    %endif

    isTokenArray %2
    %if __1
        splitArrayToElements %2
        %xdefine %?elements __1
        addrOf %1,rax,"",0
        %xdefine %?base __1
        %if listPointer(%1)
            %assign %?size 8
        %else
            %assign %?size size(%1)
        %endif

        %assign %?i 0
        %rep listlen(%?elements)
            doubleMemoryMov [%?base+%eval(%?size*%?i)],listIndex(%?elements,%?i),%?size
            %assign %?i %?i+1
        %endrep
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
        removeIndex %1
        %xdefine %?tok __1
        %ifnum size(%?tok)
            retm size(%?tok)
        %else
            isTokenFloat %?tok
            %if __1
                retm 8
            %elifnum %1
                retm numSize(%1)
            %else
                retm 0
            %endif
        %endif
    %endif
%endmacro