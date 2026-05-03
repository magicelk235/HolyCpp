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

%macro __bool.bnot 2
    mov rax,%1
    cmp rax,false
    sete al
    mov %2,al
%endmacro

%macro __bool.bor 3
    %if size(%3) == 1
        mov al,%1
        lxd %2,al
        or al,__1
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        or ax,__1
    %elif size(%3) == 4
        mov eax,%1
        lxd %2,eax
        or eax,__1
    %else
        mov rax,%1
        lxd %2,rax
        or rax,__1
    %endif
    setne al
    mov %3,al
%endmacro

%macro __bool.bxor 3
    mov rbx,%1
    cmp rbx,0
    setne al
    mov rbx,%1
    cmp rbx,0
    setne bl
    xor al,bl
    mov %3,al
%endmacro

%macro __bool.band 3
    mov rax,%1
    cmp rax,0
    je %%false
    mov rax,%2
    cmp rax,0
    je %%false
    mov %3,1
    jmp %%end
    %%false:
    mov %3,0
    %%end:
%endmacro
