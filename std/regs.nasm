; reg(size,regGroup) -> reg
%define reg(size,group) __ %+ size %+ _ %+ group

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

%define isXmmReg(reg) %eval(%isidn(size(reg),16))

; checks if a token is a register
%define isReg(token) %isnum(group(token))

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

; sizename(size)-> sizeInName
%define sizename(x) __sizename_ %+x
    %define __sizename_1 byte
    %define __sizename_2 word
    %define __sizename_4 dword
    %define __sizename_8 qword
