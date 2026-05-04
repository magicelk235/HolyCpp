; reg(size,regGroup) -> reg
%define reg(size,group) __reg@ %+ size %+ @ %+ group

    %define __reg@1@0 al
    %define __reg@2@0 ax
    %define __reg@4@0 eax
    %define __reg@8@0 rax

    %define __reg@1@1 bl
    %define __reg@2@1 bx
    %define __reg@4@1 ebx
    %define __reg@8@1 rbx

    %define __reg@1@2 cl
    %define __reg@2@2 cx
    %define __reg@4@2 ecx
    %define __reg@8@2 rcx

    %define __reg@1@3 dl
    %define __reg@2@3 dx
    %define __reg@4@3 edx
    %define __reg@8@3 rdx

    %define __reg@1@4 sil
    %define __reg@2@4 si
    %define __reg@4@4 esi
    %define __reg@8@4 rsi

    %define __reg@1@5 dil
    %define __reg@2@5 di
    %define __reg@4@5 edi
    %define __reg@8@5 rdi

    %define __reg@1@6 r8b
    %define __reg@2@6 r8w
    %define __reg@4@6 r8d
    %define __reg@8@6 r8

    %define __reg@1@7 r9b
    %define __reg@2@7 r9w
    %define __reg@4@7 r9d
    %define __reg@8@7 r9

    %define __reg@1@8 r10b
    %define __reg@2@8 r10w
    %define __reg@4@8 r10d
    %define __reg@8@8 r10

    %define __reg@1@9 r11b
    %define __reg@2@9 r11w
    %define __reg@4@9 r11d
    %define __reg@8@9 r11

    %define __reg@1@10 r12b
    %define __reg@2@10 r12w
    %define __reg@4@10 r12d
    %define __reg@8@10 r12

    %define __reg@1@11 r13b
    %define __reg@2@11 r13w
    %define __reg@4@11 r13d
    %define __reg@8@11 r13

    %define __reg@1@12 r14b
    %define __reg@2@12 r14w
    %define __reg@4@12 r14d
    %define __reg@8@12 r14

    %define __reg@1@13 r15b
    %define __reg@2@13 r15w
    %define __reg@4@13 r15d
    %define __reg@8@13 r15

    %define __reg@16@14 xmm0
    %define __reg@16@15 xmm1
    %define __reg@16@16 xmm2
    %define __reg@16@17 xmm3
    %define __reg@16@18 xmm4
    %define __reg@16@19 xmm5
    %define __reg@16@20 xmm6
    %define __reg@16@21 xmm7


    %define __reg@1@22 bpl
    %define __reg@2@22 bp
    %define __reg@4@22 ebp
    %define __reg@8@22 rbp

    %define __reg@1@23 spl
    %define __reg@2@23 sp
    %define __reg@4@23 esp
    %define __reg@8@23 rsp

    %define __reg@2@24 ip
    %define __reg@4@24 eip
    %define __reg@8@24 rip
; group(reg) -> groupID
%define group(x) __ %+ x %+ @reg@group
    %define __al@reg@group 0
    %define __ah@reg@group 0
    %define __ax@reg@group 0
    %define __eax@reg@group 0
    %define __rax@reg@group 0

    %define __bl@reg@group 1
    %define __bh@reg@group 1
    %define __bx@reg@group 1
    %define __ebx@reg@group 1
    %define __rbx@reg@group 1

    %define __cl@reg@group 2
    %define __ch@reg@group 2
    %define __cx@reg@group 2
    %define __ecx@reg@group 2
    %define __rcx@reg@group 2

    %define __dl@reg@group 3
    %define __dh@reg@group 3
    %define __dx@reg@group 3
    %define __edx@reg@group 3
    %define __rdx@reg@group 3

    %define __rsi@reg@group 4
    %define __esi@reg@group 4
    %define __si@reg@group 4
    %define __sil@reg@group 4

    %define __edi@reg@group 5
    %define __rdi@reg@group 5
    %define __di@reg@group 5
    %define __dil@reg@group 5

    %define __r8@reg@group 6
    %define __r8d@reg@group 6
    %define __r8w@reg@group 6
    %define __r8b@reg@group 6

    %define __r9@reg@group 7
    %define __r9d@reg@group 7
    %define __r9w@reg@group 7
    %define __r9b@reg@group 7

    %define __r10@reg@group 8
    %define __r10d@reg@group 8
    %define __r10w@reg@group 8
    %define __r10b@reg@group 8

    %define __r11@reg@group 9
    %define __r11d@reg@group 9
    %define __r11w@reg@group 9
    %define __r11b@reg@group 9

    %define __r12@reg@group 10
    %define __r12d@reg@group 10
    %define __r12w@reg@group 10
    %define __r12b@reg@group 10

    %define __r13@reg@group 11
    %define __r13d@reg@group 11
    %define __r13w@reg@group 11
    %define __r13b@reg@group 11

    %define __r14@reg@group 12
    %define __r14d@reg@group 12
    %define __r14w@reg@group 12
    %define __r14b@reg@group 12

    %define __r15@reg@group 13
    %define __r15d@reg@group 13
    %define __r15w@reg@group 13
    %define __r15b@reg@group 13

    %define __xmm0@reg@group 14
    %define __xmm1@reg@group 15
    %define __xmm2@reg@group 16
    %define __xmm3@reg@group 17
    %define __xmm4@reg@group 18
    %define __xmm5@reg@group 19
    %define __xmm6@reg@group 20
    %define __xmm7@reg@group 21

    %define __bpl@reg@group 22
    %define __bp@reg@group 22
    %define __ebp@reg@group 22
    %define __rbp@reg@group 22

    %define __spl@reg@group 23
    %define __sp@reg@group 23
    %define __esp@reg@group 23
    %define __rsp@reg@group 23

%define isXmmReg(reg) %eval(%isidn(size(reg),16))

; checks if a token is a register
%define isReg(token) %isnum(group(token))

; size(reg/ref) -> size
%define size(x) __ %+ x %+ @size
    %define __bl@size 1
    %define __bh@size 1
    %define __bx@size 2
    %define __ebx@size 4
    %define __rbx@size 8

    %define __al@size 1
    %define __ah@size 1
    %define __ax@size 2
    %define __eax@size 4
    %define __rax@size 8

    %define __cl@size 1
    %define __ch@size 1
    %define __cx@size 2
    %define __ecx@size 4
    %define __rcx@size 8

    %define __dl@size 1
    %define __dh@size 1
    %define __dx@size 2
    %define __edx@size 4
    %define __rdx@size 8

    %define __sil@size 1
    %define __dil@size 1
    %define __si@size 2
    %define __di@size 2
    %define __esi@size 4
    %define __edi@size 4
    %define __rdi@size 8
    %define __rsi@size 8

    %define __bpl@size 1
    %define __bp@size 2
    %define __ebp@size 4
    %define __rbp@size 8

    %define __spl@size 1
    %define __sp@size 2
    %define __esp@size 4
    %define __rsp@size 8

    %define __ip@size 2
    %define __eip@size 4
    %define __rip@size 8

    %define __r8@size 8
    %define __r9@size 8
    %define __r10@size 8
    %define __r11@size 8
    %define __r12@size 8
    %define __r13@size 8
    %define __r14@size 8
    %define __r15@size 8
    %define __r8d@size 4
    %define __r9d@size 4
    %define __r10d@size 4
    %define __r11d@size 4
    %define __r12d@size 4
    %define __r13d@size 4
    %define __r14d@size 4
    %define __r15d@size 4
    %define __r8w@size 2
    %define __r9w@size 2
    %define __r10w@size 2
    %define __r11w@size 2
    %define __r12w@size 2
    %define __r13w@size 2
    %define __r14w@size 2
    %define __r15w@size 2
    %define __r8b@size 1
    %define __r9b@size 1
    %define __r10b@size 1
    %define __r11b@size 1
    %define __r12b@size 1
    %define __r13b@size 1
    %define __r14b@size 1
    %define __r15b@size 1

    %define __xmm0@size 16
    %define __xmm1@size 16
    %define __xmm2@size 16
    %define __xmm3@size 16
    %define __xmm4@size 16
    %define __xmm5@size 16
    %define __xmm6@size 16
    %define __xmm7@size 16

; sizename(size)-> sizeInName
%define sizename(x) __sizename@ %+ x
    %define __sizename@1 byte
    %define __sizename@2 word
    %define __sizename@4 dword
    %define __sizename@8 qword
