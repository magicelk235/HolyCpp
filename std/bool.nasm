%define true 1
%define false 0

; cmp(var1,var2,dest)
%macro cmp 2-3
    %if %0 == 2
        cmp %1,%2
        %exitmacro
    %endif

    isInputFloat %1,%2,%3
    %if __1
        mov xmm0,%1
        mov xmm1,%2
        ucomisd xmm0, xmm1
    %elif size(%3) == 1
        mov al,%1
        lxd %2,al
        cmp al,__1
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        cmp ax,__1
    %elif size(%3)==4
        mov eax,%1
        lxd %2,eax
        cmp eax,__1
    %else
        mov rax,%1
        lxd %2,rax
        cmp rax,__1
    %endif
%endmacro

%macro eq 3
    cmp %1,%2,%3
    sete al
    mov %3,al
%endmacro

; var,dest
%macro bnot 2
    lxd %1,%2
    cmp __1,false
    sete al
    mov %2,al
%endmacro

; var1,var2,dest
; var1<var2
%macro lower 3
    cmp %1,%2,%3
    setl al
    mov %3,al 
%endmacro

; var1,var2,dest
; var1>var2
%macro greater 3
    cmp %1,%2,%3
    setg al
    mov %3,al 
%endmacro

; var1,var2,dest
; var1<=var2
%macro lowerEq 3
    cmp %1,%2,%3
    setle al
    mov %3,al 
%endmacro

; var1,var2,dest
; var1>=var2
%macro greaterEq 3
    cmp %1,%2,%3
    setge al
    mov %3,al 
%endmacro

%macro bOr 3
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

%macro bXor 3
    %if size(%3) == 1
        mov al,%1
        lxd %2,al
        xor al,__1
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        xor ax,__1
    %elif size(%3) == 4
        mov eax,%1
        lxd %2,eax
        xor eax,__1
    %else
        mov rax,%1
        lxd %2,rax
        xor rax,__1
    %endif
    setne al
    mov %3,al
%endmacro

%macro bAnd 3
    %if size(%3) == 1
        mov al,%1
        lxd %2,al
        and al,__1
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        and ax,__1
    %elif size(%3) == 4
        mov eax,%1
        lxd %2,eax
        and eax,__1
    %else
        mov rax,%1
        lxd %2,rax
        and rax,__1
    %endif
    setne al
    mov %3,al
%endmacro