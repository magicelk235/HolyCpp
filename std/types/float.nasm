; .set *
; .cmp *
; .equ *
; .nequ *
; .low *
; .high *
; .lequ *
; .hequ *
; .add *
; .sub *
; .mul *
; .div *
; .mod x
; .pow *
; .neg *
; .inc x
; .dec x
; .bnot x
; .bor x
; .bxor x
; .band x
; .not *
; .or *
; .xor *
; .and *
; .shr *
; .shl *

%define __float.set __unint.set
%define __float.not __unint.not
%define __float.or __unint.or
%define __float.xor __unint.xor
%define __float.and __unint.and
%define __float.shr __unint.shr
%define __float.shl __unint.shl

%macro __float.cmp 3
    mov xmm0,%1
    mov xmm1,%2
    ucomisd xmm0,xmm1
%endmacro

%macro __float.equ 3
    __float.cmp %1,%2,%3
    sete al
    mov %3,al
%endmacro

%macro __float.nequ 3
    __float.cmp %1,%2,%3
    setne al
    mov %3,al
%endmacro

%macro __float.low 3
    __float.cmp %1,%2,%3
    setb al
    mov %3,al
%endmacro

%macro __float.high 3
    __float.cmp %1,%2,%3
    seta al
    mov %3,al
%endmacro

%macro __float.lequ 3
    __float.cmp %1,%2,%3
    setbe al
    mov %3,al
%endmacro

%macro __float.hequ 3
    __float.cmp %1,%2,%3
    setae al
    mov %3,al
%endmacro

%macro __float.add 3
    mov xmm0,%1
    mov xmm1,%2
    addsd xmm0,xmm1
    mov %3,xmm0
%endmacro

%macro __float.sub 3
    mov xmm0,%1
    mov xmm1,%2
    subsd xmm0,xmm1
    mov %3,xmm0
%endmacro

%macro __float.mul 3
    mov xmm0,%1
    mov xmm1,%2
    mulsd xmm0,xmm1
    mov %3,xmm0
%endmacro

%macro __float.div 3
    mov xmm0,%1
    mov xmm1,%2
    divsd xmm0,xmm1
    mov %3,xmm0
%endmacro

%macro __float.neg 2
    mov xmm0,%1
    pxor xmm1,xmm1
    subsd xmm1,xmm0
    mov %2,xmm1
%endmacro

%macro __float.pow 3
    mov xmm0,%1
    mov rcx,%2
    movsd xmm1,[%%one]

    cmp rcx,0
    je %%exit

    %%loop:
    mulsd xmm1,xmm0
    dec rcx
    jnz %%loop

    %%exit:
    mov %3,xmm1
    jmp %%done
    %%one: dq 1.0
    %%done:
%endmacro