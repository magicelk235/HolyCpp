; .set *
; .cmp *
; .equ *
; .nequ *
; .low x
; .high x
; .lequ x
; .hequ x
; .add x
; .sub x
; .mul x
; .div x
; .mod x
; .pow x
; .neg x
; .inc x
; .dec x
; .bnot *
; .bor *
; .bxor *
; .band *
; .not x
; .or x
; .xor x
; .and x
; .shr x
; .shl x

%define __bool.set __int.set
%define __bool.cmp __int.cmp
%define __bool.equ __int.equ
%define __bool.nequ __int.nequ

newType bool,1

%macro __bool.bnot 2
    mov rax,%1
    cmp rax,false
    sete al
    mov %2,al
%endmacro

%macro __bool.bor 3
    mov al,%1
    lxd %2,al
    or al,__1
    mov %3,al
%endmacro

%macro __bool.bxor 3
    mov bl,%1
    cmp bl,0
    setne al
    mov bl,%2
    cmp bl,0
    setne bl
    xor al,bl
    mov %3,al
%endmacro

%macro __bool.band 3
    mov al,%1
    cmp al,0
    je %%false
    mov al,%2
    cmp al,0
    je %%false
    mov %3,1
    jmp %%end
    %%false:
    mov %3,0
    %%end:
%endmacro
