%assign listSizeOffset 8
; load ref's address
%macro lea 2
    %ifnum isPtr(%2)
        %if isPtr(%2)
            mov %1,ref(%2)
        %else
            lea %1,[ref(%2)]
        %endif
    %else
        lea %1,%2
    %endif
%endmacro

; setFloat(name-1,value-2)
%macro setFloat 2 
    %ifnum group(%1)
    %else
        splitIndex %1
        %xdefine __float_%+%[__0] %2
    %endif
%endmacro

; desc(name-1,size-2,ref-3,isPtr-4)
%macro desc 4
    %xdefine __size_%1 %2 ;-> __size_%$name 
    %xdefine __ref_%1 %3; -> %$name -> ref
    %xdefine __isPtr_%1 %4 ; -> isptr
    setFloat %1,0
%endmacro

; newg(name-1,size-2,times-3)
%macro newg 2-3
    section .bss
    %if %0 = 2
        __global_label_%1 resb %2
    %else
        __global_label_%1 resb listSizeOffset
        resb %3*%2
        section .text
        
        mov [__global_label_%1],%eval(%2*%3),8,8
    %endif
    desc %1,%2,__global_label_%1,0
    section .text
%endmacro

%define float(name) __float_ %+ name
 
; ref(name-1)
%define ref(name) __ref_ %+ name

%define isPtr(name) __isPtr_ %+ name

; sizename(sizeInBytes)-> name
%define sizename(x) __sizename_ %+x
    %define __sizename_1 byte
    %define __sizename_2 word
    %define __sizename_4 dword
    %define __sizename_8 qword

; size(reg/ref) -> sizeInBytes
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

; reg(sizeInBytes,regGroup) -> reg
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

; search for [ at start
; isDirectMemory(token)
%macro isDirectMemory 1
    findInToken %1,[
    %if __0 == 0
        retm 1
    %else
        retm 0
    %endif
%endmacro

; isReg(token)
%macro isReg 1
    %ifnum group(%1)
        retm 1
    %else
        retm 0
    %endif
%endmacro

; moves that works with any given size to any given size
; movSize(dest,src,ds,ss)
%macro movSize 4

    %if %3 = 16 || %4 = 16
        %if %3 = 16 && %4 = 16
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
        %endif
    %elif %3 >= %4
        %if %3 = %4
            mov sizename(%3) %1, sizename(%3) %2
        %else
            %if %4 != 4
                movsx sizename(%3) %1, sizename(%4) %2
            %else
                movsxd qword %1, dword %2
            %endif
        %endif
    %else
        %xdefine %%gid group(%2)
        mov %1, reg(%3, %%gid)
    %endif
%endmacro

%macro sizeByToken 1
    ; register
    %ifnum group(%1)
        retm size(%1)
    ; ref
    %else
        splitIndex %1
        retm size( __0 )
    %endif
%endmacro

;lsd
%macro lsd 2
    ; const number check
    TokenToNum %1
    %ifnum __0
        %assign %%const __0
        setFloat %2,__1
        isReg %2
        %xdefine %%isReg __0

        isNumInSize %%const,4
        %if __0!=1 && %%isReg!=1
            resr %2
            mov r,%%const

            sizeByToken %2
            retm r,__0
            %exitmacro

        %endif

        sizeByToken %2
        retm %%const,__0
        %exitmacro
        
    %endif

    ; register check
    %ifnum group(%1)
        retm %1,size(%1)
        %exitmacro
    %endif

    ; checks for direct ref

    ; is ref ptr
    %ifidn isPtr(%1),1
        resr %2
        lea r,%1
        retm r,size(%1)
        %exitmacro
    %endif

    ; is ref !ptr
    %ifidn isPtr(%1),0
        retm [ref(%1)],size(%1)
        %exitmacro
    %endif

    ; checks for memmory
    isDirectMemory %1
    %if __0
        retm %1,size(%2)
        %exitmacro
    %endif
    retm -1,-1
%endmacro

; lxd(token1,token2)
%macro lxd 2

    lsd %1,%2
    %ifidn __1,-1
    %else
        retm __0,__1
        %exitmacro
    %endif

    ; checks for lists
    isTokenList %1
    %if __0
        getIndexOffset %1,%2
        %exitmacro
    %endif
%endmacro

%macro isMemmory 1
    isDirectMemory %1
    %if __0
        retm 1
        %exitmacro
    %endif

    %ifnum isPtr(%1)
        retm 1
        %exitmacro
    %endif

    retm 0
%endmacro


; automov(dest,src,?ds,?ss)
%macro automov 2-4
    %xdefine %%0 %0
    lxd %1,%2
    %xdefine %%dest __0

    %if %%0 == 4
        %xdefine %%ds %3
    %else
        %xdefine %%ds __1
    %endif

    lxd %2,%1
    %xdefine %%src __0

    %if %%0 == 4
        %xdefine %%ss %4
    %else
        %xdefine %%ss __1
    %endif



    movSize %%dest,%%src,%%ds,%%ss
%endmacro



; mov(dest,src,?ds,?ss)
%macro mov 2-4


    %ifidn %1,%2
        %exitmacro
    %endif


    isMemmory %1
    %xdefine %%is1Memmory __0
    isMemmory %2
    %xdefine %%is2Memmory __0

    %if %%is1Memmory && %%is2Memmory
        %if %0==2
            automov r15,%1
            automov %2,r15
        %else
            automov r15,%1
            automov %2,r15,%3,%4
        %endif
    %else
        automov %{1:-1}
    %endif
%endmacro