%assign listSizeOffset 8
; load ref's address
; lra(ref,ignored,depth)
%macro lra 2-3
    %if %0=2
        %assign %%at 0
    %else
        %assign %%at %3
    %endif
    retm 0
    %if isDirectRef(%1)
        %assign %%depth depth(%1)-%%at
        %if %%depth>0
            resr %2
            omov r,[addr(%1)]
            %rep %%depth-1
                omov r,[r]
            %endrep
            retm r
        %else
            retm addr(%1)
        %endif
    %endif
%endmacro

;  a ref or lists address
; addrOf(ref,ignored,depth)
%macro addrOf 3
    lra %1,%2,%3
    %ifidn __1,0
        getIndexOffset %1,%2
    %endif
%endmacro

; ref/list,dest,depth
%macro lea 2-3
    %if %0==2
        %assign %%depth 0
    %else
        %assign %%depth %3
    %endif

    addrOf %1,%2,%3
    %if isReg(%2)
        lea %2,[__1]
    %elif isRef(%2)
        %xdefine %%addr __1
        resr %%addr
        lea r,[%%addr]
        mov %2,r
    %else
        lea %2,[%1]
    %endif
%endmacro
; set a ref to a float
; setFloat(ref,value)
%macro setFloat 2 
    %if ! isReg(%1)
        splitIndex %1
        %xdefine __float_%[__1] %2
    %endif
%endmacro

; makes a new ref that store size,addr,depth,float,times
; newRef(ref's name,size,addr,depth,float,times)
%macro newRef 6
    %assign __size_%1 %2 ;-> __size_name 
    %xdefine __addr_%1 %3; -> __addr_name
    %assign __depth_%1 %4
    %assign __float_%1 %5
    %assign __times_%1 %6
    %xdefine __ref_%1 1
%endmacro

%define depth(x) __depth_%+x
%define times(x) __times_%+x

; makes a new global .bss variable
; newgb(name,size,times,depth)
%macro newgb 4
    section .bss
    %if %4>0
        __global_label_%1 resq 1
        section .text
    %elif %3==1
        __global_label_%1 resb %2
        section .text
    %else
        __global_label_%1 resb listSizeOffset
        resb %3*%2
        section .text
        omov qword [__global_label_%1],%3
    %endif
    retm __global_label_%1
%endmacro



; makes a new global .data variable
; newgb(name,size,times,depth,data,section)
%macro newgd 6
    section %6
    %if %4>0
        __global_label_%1 dq %5
    %elif %3==1
        %if %2==1
            __global_label_%1 db %5
        %elif %2==2
            __global_label_%1 dw %5
        %elif %2==4
            __global_label_%1 dd %5
        %else
            __global_label_%1 dq %5
        %endif
    %else
        __global_label_%1 dq %3*%2
        %ifstr %5
            db %5,0
        %else
            %push
            splitListToTokens %5
            %assign %%i 1
            %rep %$__0
                %if %2==1
                    db %[%$__%+%%i]
                %elif %2==2
                    dw %[%$__%+%%i]
                %elif %2==4
                    dd %[%$__%+%%i]
                %else
                    dq %[%$__%+%%i]
                %endif
                %assign %%i %%i+1
            %endrep
            %pop
        %endif
    %endif
    section .text
    retm __global_label_%1
%endmacro


; new(name)
%macro new 1-*
    %rep %0
        ; pointer depth searches for @
        tokenCount %1,@
        %assign %%depth __1

        replaceToken %1,@,""
        %xdefine %%name __1

        ; size search for "local,global.."
        findInToken %%name,"global "
        %if __1 != -1
            replaceToken %%name,"global ",""
            %xdefine %%name __1
            %define %%scope "g"
        %else
        findInToken %%name,"local "
        %if __1 != -1
            replaceToken %%name,"local ",""
            %xdefine %%name __1
            %define %%scope "l"
        %else
        findInToken %%name,"tbp "
        %if __1 != -1
            replaceToken %%name,"tbp ",""
            %xdefine %%name __1
            %define %%scope "tbp"
        %else
        findInToken %%name,"tsp "
        %if __1 != -1
            replaceToken %%name,"tsp ",""
            %xdefine %%name __1
            %define %%scope "tsp"
        %else
        findInToken %%name,"const "
        %if __1 != -1
            replaceToken %%name,"const ",""
            %xdefine %%name __1
            %define %%scope "c"
        %else
        findInToken %%name,"arg "
        %if __1 != -1
            replaceToken %%name,"arg ",""
            %xdefine %%name __1
            %define %%scope "arg"
        %elif inProc
            %define %%scope "l"
        %else
            %define %%scope "g"
        %endif
        %endif
        %endif
        %endif    
        %endif
        %endif

        ; qword x->
        findInToken %%name,=
        %assign %%startData %eval(__1!=-1)
        %if %%startData
            %assign %%startDataIndex __1+1
            subToken %%name,%%startDataIndex
            %xdefine %%data __1
            subToken %%name,0,%eval(%%startDataIndex-1)
            %xdefine %%name __1
        %endif
    
        ; size search for "byte,word.."
        %assign %%size 1
        findInToken %%name,"byte "
        %if __1 != -1
            replaceToken %%name,"byte ",""
            %xdefine %%name __1
            %assign %%size 1
        %else
        findInToken %%name,"qword "
        %if __1 != -1
            replaceToken %%name,"qword ",""
            %xdefine %%name __1
            %assign %%size 8
        %else
        findInToken %%name,"dword "
        %if __1 != -1
            replaceToken %%name,"dword ",""
            %xdefine %%name __1
            %assign %%size 4
        %else
        findInToken %%name,"word "
        %if __1 != -1
            replaceToken %%name,"word ",""
            %xdefine %%name __1
            %assign %%size 2
        %endif
        %endif    
        %endif
        %endif

        %assign %%float 0
        findInToken %%name,.
        %if __1!=-1
            replaceToken %%name,.,""
            %xdefine %%name __1
            %assign %%float 1
        %endif


        ; search for [] if is an list
        findPare %%name,[,]
        %if __1 != -1
            %assign %%startIndex __1
            %assign %%stopIndex __2
            subToken %%name,%eval(%%startIndex+1),%%stopIndex
            %assign %%times __1
            subToken %%name,%%startIndex,-1
            replaceToken %%name,__1,""
            %xdefine %%name __1
        %else
            %assign %%times 1
        %endif 

        %if %%scope=="c"
            newgd %%name,%%size,%%times,%%depth,%%data,.rdata
        %elif %%scope=="g"
            %if %%startData
                newgd %%name,%%size,%%times,%%depth,%%data,.data
            %else
                newgb %%name,%%size,%%times,%%depth
            %endif
        %elif %%scope=="l"
            newl %%name,%%size,%%times,%%depth
        %elif %%scope=="a"
            arg %%name,%%size,%%times,%%depth
        %elif %%scope=="tbp"
            newtbp %%name,%%size,%%times,%%depth
        %elif %%scope=="tsp"
            newtsp %%name,%%size,%%times,%%depth
        %endif

        newRef %%name,%%size,__1,%%depth,%%float,%%times

        %if %%scope == "l" && %%startData
            mov %%name,%%data
        %endif
        %rotate 1
    %endrep
%endmacro

; set
%macro set 1
    findInToken %1,=
    %assign %%startDataIndex __1
    subToken %1,0,%%startDataIndex
    %xdefine %%name __1
    subToken %1,%eval(%%startDataIndex+1)
    eval %%name,__1
%endmacro

; gets if a ref is a float
%define float(name) __float_ %+ name
 
; gets the addr of ref
%define addr(name) __addr_ %+ name

; sizename(size)-> sizeInName
%define sizename(x) __sizename_ %+x
    %define __sizename_1 byte
    %define __sizename_2 word
    %define __sizename_4 dword
    %define __sizename_8 qword

; size(reg/ref) -> size
%define size(x) __size_%+ x
    %define __size_bl 1
    %define __size_bh 1
    %define __size_bx 2
    %define __size_ebx 4
    %define __size_rbx 8

    %define __size_al 1
    %define __size_ah 1
    %define __size_ax 2
    %define __size_eax 4
    %define __size_rax 8

    %define __size_cl 1
    %define __size_ch 1
    %define __size_cx 2
    %define __size_ecx 4
    %define __size_rcx 8

    %define __size_dl 1
    %define __size_dh 1
    %define __size_dx 2
    %define __size_edx 4
    %define __size_rdx 8

    
    %define __size_sil 1
    %define __size_dil 1
    %define __size_si 2
    %define __size_di 2
    %define __size_esi 4
    %define __size_edi 4
    %define __size_rdi 8
    %define __size_rsi 8

    %define __size_bpl 1
    %define __size_bp 2
    %define __size_ebp 4
    %define __size_rbp 8

    %define __size_spl 1
    %define __size_sp 2
    %define __size_esp 4
    %define __size_rsp 8

    %define __size_ip 2
    %define __size_eip 4
    %define __size_rip 8

    %define __size_r8 8
    %define __size_r9 8
    %define __size_r10 8
    %define __size_r11 8
    %define __size_r12 8
    %define __size_r13 8
    %define __size_r14 8
    %define __size_r15 8
    %define __size_r8d 4
    %define __size_r9d 4
    %define __size_r10d 4
    %define __size_r11d 4
    %define __size_r12d 4
    %define __size_r13d 4
    %define __size_r14d 4
    %define __size_r15d 4
    %define __size_r8w 2
    %define __size_r9w 2
    %define __size_r10w 2
    %define __size_r11w 2
    %define __size_r12w 2
    %define __size_r13w 2
    %define __size_r14w 2
    %define __size_r15w 2
    %define __size_r8b 1
    %define __size_r9b 1
    %define __size_r10b 1
    %define __size_r11b 1
    %define __size_r12b 1
    %define __size_r13b 1
    %define __size_r14b 1
    %define __size_r15b 1

    %define __size_xmm0 16
    %define __size_xmm1 16
    %define __size_xmm2 16
    %define __size_xmm3 16
    %define __size_xmm4 16
    %define __size_xmm5 16
    %define __size_xmm6 16
    %define __size_xmm7 16

; reg(size,regGroup) -> reg
%define reg(sz,grp) __ %+ sz %+ _ %+ grp

    %define __1_0 al
    %define __2_0 ax
    %define __4_0 eax
    %define __8_0 rax

    %define __1_1 bl
    %define __2_1 bx
    %define __4_1 ebx
    %define __8_1 rbx

    %define __1_2 cl
    %define __2_2 cx
    %define __4_2 ecx
    %define __8_2 rcx

    %define __1_3 dl
    %define __2_3 dx
    %define __4_3 edx
    %define __8_3 rdx

    %define __1_4 sil
    %define __2_4 si
    %define __4_4 esi
    %define __8_4 rsi

    %define __1_5 dil
    %define __2_5 di
    %define __4_5 edi
    %define __8_5 rdi
    
    %define __1_6 r8b
    %define __2_6 r8w
    %define __4_6 r8d
    %define __8_6 r8

    %define __1_7 r9b
    %define __2_7 r9w
    %define __4_7 r9d
    %define __8_7 r9

    %define __1_8 r10b
    %define __2_8 r10w
    %define __4_8 r10d
    %define __8_8 r10

    %define __1_9 r11b
    %define __2_9 r11w
    %define __4_9 r11d
    %define __8_9 r11

    %define __1_10 r12b
    %define __2_10 r12w
    %define __4_10 r12d
    %define __8_10 r12

    %define __1_11 r13b
    %define __2_11 r13w
    %define __4_11 r13d
    %define __8_11 r13

    %define __1_12 r14b
    %define __2_12 r14w
    %define __4_12 r14d
    %define __8_12 r14

    %define __1_13 r15b
    %define __2_13 r15w
    %define __4_13 r15d
    %define __8_13 r15

    %define __16_14 xmm0
    %define __16_15 xmm1
    %define __16_16 xmm2
    %define __16_17 xmm3
    %define __16_18 xmm4
    %define __16_19 xmm5
    %define __16_20 xmm6
    %define __16_21 xmm7
    

    %define __1_22 bpl
    %define __2_22 bp
    %define __4_22 ebp
    %define __8_22 rbp

    %define __1_23 spl
    %define __2_23 sp
    %define __4_23 esp
    %define __8_23 rsp

    %define __2_24 ip
    %define __4_24 eip
    %define __8_24 rip
; group(reg) -> groupID
%define group(x) __group_ %+ x
    %define __group_al 0
    %define __group_ah 0
    %define __group_ax 0
    %define __group_eax 0
    %define __group_rax 0


    %define __group_bl 1
    %define __group_bh 1
    %define __group_bx 1
    %define __group_ebx 1
    %define __group_rbx 1


    %define __group_cl 2
    %define __group_ch 2
    %define __group_cx 2
    %define __group_ecx 2
    %define __group_rcx 2

    %define __group_dl 3
    %define __group_dh 3
    %define __group_dx 3
    %define __group_edx 3
    %define __group_rdx 3

    %define __group_rsi 4
    %define __group_esi 4
    %define __group_si 4
    %define __group_sil 4

    %define __group_edi 5
    %define __group_rdi 5
    %define __group_di 5
    %define __group_dil 5
    
    %define __group_r8 6
    %define __group_r8d 6
    %define __group_r8w 6    
    %define __group_r8b 6

    %define __group_r9 7
    %define __group_r9d 7
    %define __group_r9w 7
    %define __group_r9b 7

    %define __group_r10 8
    %define __group_r10d 8
    %define __group_r10w 8
    %define __group_r10b 8
    
    %define __group_r11 9
    %define __group_r11d 9    
    %define __group_r11w 9
    %define __group_r11b 9

    %define __group_r12 10
    %define __group_r12d 10
    %define __group_r12w 10
    %define __group_r12b 10

    %define __group_r13 11
    %define __group_r13d 11
    %define __group_r13w 11
    %define __group_r13b 11
    
    %define __group_r14 12
    %define __group_r14d 12
    %define __group_r14w 12
    %define __group_r14b 12

    %define __group_r15 13
    %define __group_r15d 13
    %define __group_r15w 13
    %define __group_r15b 13

    %define __group_xmm0 14
    %define __group_xmm1 15
    %define __group_xmm2 16
    %define __group_xmm3 17
    %define __group_xmm4 18
    %define __group_xmm5 19
    %define __group_xmm6 20
    %define __group_xmm7 21

    %define __group_bpl 22
    %define __group_bp 22
    %define __group_ebp 22
    %define __group_rbp 22

    %define __group_spl 23
    %define __group_sp 23
    %define __group_esp 23
    %define __group_rsp 23

    %define __group_ip 24
    %define __group_eip 24
    %define __group_rip 24

%define isXmmReg(reg) %eval(%isidn(size(reg),16))

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

; checks if a token is a register
%define isReg(token) %isnum(group(token))


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

%define isRef(x) %isnum(__ref_%+x)
%define isDirectRef(x) %isidn(__ref_ %+ x,1)

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
        lra %%ref,%2,%%at
        retm [__1],size(%%ref)
        %exitmacro
    %endif

    ; checks for direct ref
    %if isDirectRef(%1)
        lra %1,%2
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

    ; checks for lists
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

%define oldAutomovDest 0
%define oldAutomovSrc 0

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

    %ifidn %%dest,%%src
        %exitmacro
    %elif %isidn(%%dest,oldAutomovDest) && %isidn(%%src,oldAutomovSrc)
        %exitmacro
    %elif %isidn(%%src,oldAutomovDest) && %isidn(%%dest,oldAutomovSrc)
        %exitmacro
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


%define oldMovDest 0
%define oldMovSrc 0
%define inMov 0

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
    %define inMov 1

    %if isRef(%1)&&%isstr(%2)
        %xdefine %%str %2
        %strlen %%strlen %%str
        addrOf %1,rbx,0
        omov qword [__1],%%strlen
        %assign __times%+%1 %%strlen
        %assign %%i 1
        %rep %%strlen
            %substr %%char %%str %%i
            omov byte [__1 + %%i-1 + listSizeOffset],%%char
            %assign %%i %%i+1
        %endrep
        omov byte [__1 + %%i-1 + listSizeOffset],0
        %define inMov 0
        %exitmacro
    %endif

    isTokenList %2
    %if __1
        %push
        splitListToTokens %2
        addrOf %1,rax,0
        %xdefine %%addr __1
        %assign %%i 1
        %rep %$__0
            doubleMemoryMov [%%addr+size(%1)*(%%i-1)+ listSizeOffset],%$__%[%%i],size(%1)
            %assign %%i %%i+1
        %endrep
        %pop
        %define inMov 0
        %exitmacro
    %endif
    doubleMemoryMov %{1:-1}
    %define inMov 0
%endmacro