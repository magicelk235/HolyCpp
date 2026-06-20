%define reg(size,group) merge(merge(merge(__reg@, size), @), group)

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

    %define __reg@32@14 ymm0
    %define __reg@32@15 ymm1
    %define __reg@32@16 ymm2
    %define __reg@32@17 ymm3
    %define __reg@32@18 ymm4
    %define __reg@32@19 ymm5
    %define __reg@32@20 ymm6
    %define __reg@32@21 ymm7

    %define __reg@64@14 zmm0
    %define __reg@64@15 zmm1
    %define __reg@64@16 zmm2
    %define __reg@64@17 zmm3
    %define __reg@64@18 zmm4
    %define __reg@64@19 zmm5
    %define __reg@64@20 zmm6
    %define __reg@64@21 zmm7


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

%define group(reg) merge(__reg@group@, reg)
    %define __reg@group@al 0
    %define __reg@group@ah 0
    %define __reg@group@ax 0
    %define __reg@group@eax 0
    %define __reg@group@rax 0

    %define __reg@group@bl 1
    %define __reg@group@bh 1
    %define __reg@group@bx 1
    %define __reg@group@ebx 1
    %define __reg@group@rbx 1

    %define __reg@group@cl 2
    %define __reg@group@ch 2
    %define __reg@group@cx 2
    %define __reg@group@ecx 2
    %define __reg@group@rcx 2

    %define __reg@group@dl 3
    %define __reg@group@dh 3
    %define __reg@group@dx 3
    %define __reg@group@edx 3
    %define __reg@group@rdx 3

    %define __reg@group@rsi 4
    %define __reg@group@esi 4
    %define __reg@group@si 4
    %define __reg@group@sil 4

    %define __reg@group@edi 5
    %define __reg@group@rdi 5
    %define __reg@group@di 5
    %define __reg@group@dil 5

    %define __reg@group@r8 6
    %define __reg@group@r8d 6
    %define __reg@group@r8w 6
    %define __reg@group@r8b 6

    %define __reg@group@r9 7
    %define __reg@group@r9d 7
    %define __reg@group@r9w 7
    %define __reg@group@r9b 7

    %define __reg@group@r10 8
    %define __reg@group@r10d 8
    %define __reg@group@r10w 8
    %define __reg@group@r10b 8

    %define __reg@group@r11 9
    %define __reg@group@r11d 9
    %define __reg@group@r11w 9
    %define __reg@group@r11b 9

    %define __reg@group@r12 10
    %define __reg@group@r12d 10
    %define __reg@group@r12w 10
    %define __reg@group@r12b 10

    %define __reg@group@r13 11
    %define __reg@group@r13d 11
    %define __reg@group@r13w 11
    %define __reg@group@r13b 11

    %define __reg@group@r14 12
    %define __reg@group@r14d 12
    %define __reg@group@r14w 12
    %define __reg@group@r14b 12

    %define __reg@group@r15 13
    %define __reg@group@r15d 13
    %define __reg@group@r15w 13
    %define __reg@group@r15b 13

    %define __reg@group@xmm0 14
    %define __reg@group@xmm1 15
    %define __reg@group@xmm2 16
    %define __reg@group@xmm3 17
    %define __reg@group@xmm4 18
    %define __reg@group@xmm5 19
    %define __reg@group@xmm6 20
    %define __reg@group@xmm7 21

    %define __reg@group@ymm0 14
    %define __reg@group@ymm1 15
    %define __reg@group@ymm2 16
    %define __reg@group@ymm3 17
    %define __reg@group@ymm4 18
    %define __reg@group@ymm5 19
    %define __reg@group@ymm6 20
    %define __reg@group@ymm7 21

    %define __reg@group@zmm0 14
    %define __reg@group@zmm1 15
    %define __reg@group@zmm2 16
    %define __reg@group@zmm3 17
    %define __reg@group@zmm4 18
    %define __reg@group@zmm5 19
    %define __reg@group@zmm6 20
    %define __reg@group@zmm7 21

    %define __reg@group@bpl 22
    %define __reg@group@bp 22
    %define __reg@group@ebp 22
    %define __reg@group@rbp 22

    %define __reg@group@spl 23
    %define __reg@group@sp 23
    %define __reg@group@esp 23
    %define __reg@group@rsp 23

%define isXmmReg(reg) %eval(isReg(reg)&&%isidn(regsize(reg),16))
%define isYmmReg(reg) %eval(isReg(reg)&&%isidn(regsize(reg),32))
%define isZmmReg(reg) %eval(isReg(reg)&&%isidn(regsize(reg),64))
%define isSimdReg(reg) %eval(isXmmReg(reg)||isYmmReg(reg)||isZmmReg(reg))

%define isReg(token) %isnum(group(token))

%define regsize(x) merge(__reg@size@, x)
    %define __reg@size@bl 1
    %define __reg@size@bh 1
    %define __reg@size@bx 2
    %define __reg@size@ebx 4
    %define __reg@size@rbx 8

    %define __reg@size@al 1
    %define __reg@size@ah 1
    %define __reg@size@ax 2
    %define __reg@size@eax 4
    %define __reg@size@rax 8

    %define __reg@size@cl 1
    %define __reg@size@ch 1
    %define __reg@size@cx 2
    %define __reg@size@ecx 4
    %define __reg@size@rcx 8

    %define __reg@size@dl 1
    %define __reg@size@dh 1
    %define __reg@size@dx 2
    %define __reg@size@edx 4
    %define __reg@size@rdx 8

    %define __reg@size@sil 1
    %define __reg@size@dil 1
    %define __reg@size@si 2
    %define __reg@size@di 2
    %define __reg@size@esi 4
    %define __reg@size@edi 4
    %define __reg@size@rdi 8
    %define __reg@size@rsi 8

    %define __reg@size@bpl 1
    %define __reg@size@bp 2
    %define __reg@size@ebp 4
    %define __reg@size@rbp 8

    %define __reg@size@spl 1
    %define __reg@size@sp 2
    %define __reg@size@esp 4
    %define __reg@size@rsp 8

    %define __reg@size@ip 2
    %define __reg@size@eip 4
    %define __reg@size@rip 8

    %define __reg@size@r8 8
    %define __reg@size@r9 8
    %define __reg@size@r10 8
    %define __reg@size@r11 8
    %define __reg@size@r12 8
    %define __reg@size@r13 8
    %define __reg@size@r14 8
    %define __reg@size@r15 8
    %define __reg@size@r8d 4
    %define __reg@size@r9d 4
    %define __reg@size@r10d 4
    %define __reg@size@r11d 4
    %define __reg@size@r12d 4
    %define __reg@size@r13d 4
    %define __reg@size@r14d 4
    %define __reg@size@r15d 4
    %define __reg@size@r8w 2
    %define __reg@size@r9w 2
    %define __reg@size@r10w 2
    %define __reg@size@r11w 2
    %define __reg@size@r12w 2
    %define __reg@size@r13w 2
    %define __reg@size@r14w 2
    %define __reg@size@r15w 2
    %define __reg@size@r8b 1
    %define __reg@size@r9b 1
    %define __reg@size@r10b 1
    %define __reg@size@r11b 1
    %define __reg@size@r12b 1
    %define __reg@size@r13b 1
    %define __reg@size@r14b 1
    %define __reg@size@r15b 1

    %define __reg@size@xmm0 16
    %define __reg@size@xmm1 16
    %define __reg@size@xmm2 16
    %define __reg@size@xmm3 16
    %define __reg@size@xmm4 16
    %define __reg@size@xmm5 16
    %define __reg@size@xmm6 16
    %define __reg@size@xmm7 16

    %define __reg@size@ymm0 32
    %define __reg@size@ymm1 32
    %define __reg@size@ymm2 32
    %define __reg@size@ymm3 32
    %define __reg@size@ymm4 32
    %define __reg@size@ymm5 32
    %define __reg@size@ymm6 32
    %define __reg@size@ymm7 32

    %define __reg@size@zmm0 64
    %define __reg@size@zmm1 64
    %define __reg@size@zmm2 64
    %define __reg@size@zmm3 64
    %define __reg@size@zmm4 64
    %define __reg@size@zmm5 64
    %define __reg@size@zmm6 64
    %define __reg@size@zmm7 64


%define sizename(size) merge(__sizename@, size)
    %define __sizename@1 byte
    %define __sizename@2 word
    %define __sizename@4 dword
    %define __sizename@8 qword

%define isGPR(reg) %cond(isReg(reg),group(reg)<group(xmm0),0)
%define reg8bytes(reg) reg(8,%eval(group(reg)))
%define isDataLoaded(data) indict(__reg@regDesc,data)&&!poolin(dictkey(__reg@regDesc,data),__reg@unusedReg)

%define @ext r8,r9,r10,r11,r12,r13,r14,r15
%define @general rax,rbx,rcx,rdx,rsi,rdi 
%define @float xmm1,xmm2,xmm3,xmm4,xmm5,xmm6,xmm7
%define @all @general,@ext,@float

newDict __reg@regDesc
newPool __reg@unusedReg,@general,@ext
newDict __reg@regUsage

; tuple/pool/list
; {ignored},?{scratch}=0,?size=8
%macro allocr 1-3 0,8

    %xdefine %?tuple %1

    %if %count(%[%1])==1
        %if ispool(%1)
            pooltotuple %1
            %xdefine %?tuple __1
        %elif islist(%1)
            listToTuple %1
            %xdefine %?tuple __1
        %endif
    %endif

    newPool %?ignored
    %assign %?i 1
    %rep %count(%[%?tuple])
        %ifnum %sel(%?i,%?tuple)
            pooladd %?ignored,%sel(%?i,%?tuple)
        %elifnum group(%sel(%?i,%?tuple))
            pooladd %?ignored,group(%sel(%?i,%?tuple))
        %endif
        %assign %?i %?i+1
    %endrep

    retm 0

    ; trying to alloc a register for the suggested scratch
    %assign %?foundReg 0
    %ifnidn %2,0
        %assign %?i 1
        %rep %count(%[%2])
            %xdefine %?r %sel(%?i,%2)
            %if isReg(%?r)
                %if !poolin(%?ignored,group(%?r))
                    retm reg(%3,group(%?r))
                    %exitrep
                %endif
            %endif
            %assign %?i %?i+1
        %endrep
    %endif

    %ifnidn __1,0
        %exitmacro
    %endif

    %assign %?group 0
    %rep group(xmm0)
        %if !poolin(%?ignored,%?group)
            retm reg(%3,%?group)
            %exitrep
        %endif
        %assign %?group %?group+1
    %endrep
%endmacro

%macro getLeastUsedReg 0
    %assign %?minUsage dictkey(__reg@regUsage,listIndex(dictkeyslist(__reg@regUsage),0)) ; sets the start to min
    %xdefine %?reg listIndex(dictkeyslist(__reg@regUsage),0) ; sets the start reg to minreg
    %assign %?i 1
    %rep dictlen(__reg@regUsage)-1
        %assign %?usage dictkey(__reg@regUsage,listIndex(dictkeyslist(__reg@regUsage),%?i))
        %if %?usage<%?minUsage
            %assign %?minUsage %?usage
            %xdefine %?reg listIndex(dictkeyslist(__reg@regUsage),%?i)
        %endif
        %assign %?i %?i+1
    %endrep
    retm %?reg
%endmacro

; size -> unused register
%macro resr 0-1 8
    %if poollen(__reg@unusedReg)!=0
        retm reg(%1,group(listIndex(poollist(__reg@unusedReg),0)))
    %else ; searches for the least used register
        getLeastUsedReg        
    %endif
%endmacro

; marks the register used, maps the variable to the register
; addRegDesc(register,variable)
%macro addRegDesc 2
    poolrm __reg@unusedReg,%[reg8bytes(%1)]
    dictsetkey __reg@regDesc,%2,%1
    dictsetkey __reg@regUsage,%[reg8bytes(%1)],0
%endmacro

; marks the register unused 
; rmRegDesc(register)
%macro rmRegDesc 1
    pooladd __reg@unusedReg,reg8bytes(%1)
%endmacro

;data
%macro LoadToReg 1-2 mov
    %if isDataLoaded(%1)
        retm dictkey(__reg@regDesc,%1)
    %else
        resr
        %2 r,%1
        addRegDesc r,%1
        retm r
    %endif
    dictsetkey __reg@regUsage,r,%eval(dictkey(__reg@regUsage,r)+1)
%endmacro