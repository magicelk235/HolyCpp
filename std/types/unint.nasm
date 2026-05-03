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
; .mod *
; .pow *
; .neg x
; .inc *
; .dec *
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

%define __unint.set __int.set
%define __unint.add __int.add
%define __unint.sub __int.sub
%define __unint.inc __int.inc
%define __unint.dec __int.dec
%define __unint.not __int.not
%define __unint.xor __int.xor
%define __unint.and __int.and
%define __unint.or __int.or
%define __unint.shl __int.shl
%define __unint.cmp __int.cmp
%define __unint.equ __int.equ
%define __unint.nequ __int.nequ
%define __unint.pow __int.pow

%macro __unint.low 3
    __unint.cmp %1,%2,%3
    setb al
    mov %3,al
%endmacro

%macro __unint.high 3
    __unint.cmp %1,%2,%3
    seta al
    mov %3,al
%endmacro

%macro __unint.lequ 3
    __unint.cmp %1,%2,%3
    setbe al
    mov %3,al
%endmacro

%macro __unint.hequ 3
    __unint.cmp %1,%2,%3
    setae al
    mov %3,al
%endmacro

%macro __unint.mul 3
    %if (%isnum(%2))
        %if %2>0 && isPow2(%2)
            __unint.shl %1,%eval(ilog2(%2)),%3
            %exitmacro
        %endif
    %endif

    %if (%isnum(%1))
        %if %1>0 && isPow2(%2)
            __unint.shl %2,%eval(ilog2(%1)),%3
            %exitmacro
        %endif
    %endif

    %if size(%3) == 1
        mov al,%1
        lxd %2,al
        mul byte __1
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        mul word __1
        mov %3,ax
    %elif size(%3) == 4
        mov eax,%1
        lxd %2,eax
        mul dword __1
        mov %3,eax
    %else
        mov rax,%1
        lxd %2,rax
        mul qword __1
        mov %3,rax
    %endif
%endmacro

%macro __unint.div 3
    %if (%isnum(%2))
        %if %2>0 && isPow2(%2)
            __unint.shr %1,%eval(ilog2(%2)),%3
            %exitmacro
        %endif
    %endif

    %if size(%3) == 1
        xor ah,ah
        mov al,%1
        lxd %2,al
        %if %isnum(%2)
            mov bl,%2
            div bl
        %else
            div byte __1
        %endif
        mov %3,al
    %elif size(%3) == 2
        xor dx,dx
        mov ax,%1
        lxd %2,ax
        %if %isnum(%2)
            mov bx,%2
            div bx
        %else
            div word __1
        %endif
        mov %3,ax
    %elif size(%3)==4
        xor edx,edx
        mov eax,%1
        lxd %2,eax
        %if %isnum(%2)
            mov ebx,%2
            div ebx
        %else
            div dword __1
        %endif
        mov %3,eax
    %else
        xor rdx,rdx
        mov rax,%1
        lxd %2,rax
        %if %isnum(%2)
            mov rbx,%2
            div rbx
        %else
            div qword __1
        %endif
        mov %3,rax
    %endif
%endmacro

%macro __unint.mod 3
    %if size(%3) == 1
        xor ah,ah
        mov al,%1
        lxd %2,al
        %if %isnum(%2)
            mov bl,%2
            div bl
        %else
            div byte __1
        %endif
        mov %3,ah
    %elif size(%3) == 2
        xor dx,dx
        mov ax,%1
        lxd %2,ax
        %if %isnum(%2)
            mov bx,%2
            div bx
        %else
            div word __1
        %endif
        mov %3,dx
    %elif size(%3)==4
        xor edx,edx
        mov eax,%1
        lxd %2,eax
        %if %isnum(%2)
            mov ebx,%2
            div ebx
        %else
            div dword __1
        %endif
        mov %3,edx
    %else
        xor rdx,rdx
        mov rax,%1
        lxd %2,rax
        %if %isnum(%2)
            mov rbx,%2
            div rbx
        %else
            div qword __1
        %endif
        mov %3,rdx
    %endif
%endmacro

%macro __unint.shr 3
    %if size(%3) == 1
        mov al,%1
        mov cl,%2
        shr al,cl
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        mov cl,%2
        shr ax,cl
        mov %3,ax
    %elif size(%3) == 4
        mov eax,%1
        mov cl,%2
        shr eax,cl
        mov %3,eax
    %else
        mov rax,%1
        mov cl,%2
        shr rax,cl
        mov %3,rax
    %endif
%endmacro