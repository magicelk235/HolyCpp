; and(src1,src2,dest)
%macro and 2-3
    %if %0 == 2
        and %1,%2
        %exitmacro
    %endif

    %if size(%3) == 1
        mov al,%1
        lxd %2,al
        and al,__1
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        and ax,__1
        mov %3,ax
    %elif size(%3) == 4
        mov eax,%1
        lxd %2,eax
        and eax,__1
        mov %3,eax
    %else
        mov rax,%1
        lxd %2,rax
        and rax,__1
        mov %3,rax
    %endif
%endmacro

; or(src1,src2,dest)
%macro or 2-3
    %if %0 == 2
        or %1,%2
        %exitmacro
    %endif

    %if size(%3) == 1
        mov al,%1
        lxd %2,al
        or al,__1
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        or ax,__1
        mov %3,ax
    %elif size(%3) == 4
        mov eax,%1
        lxd %2,eax
        or eax,__1
        mov %3,eax
    %else
        mov rax,%1
        lxd %2,rax
        or rax,__1
        mov %3,rax
    %endif
%endmacro

; xor(src1,src2,dest)
%macro xor 2-3
    %if %0 == 2
        xor %1,%2
        %exitmacro
    %endif

    %if size(%3) == 1
        mov al,%1
        lxd %2,al
        xor al,__1
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        xor ax,__1
        mov %3,ax
    %elif size(%3) == 4
        mov eax,%1
        lxd %2,eax
        xor eax,__1
        mov %3,eax
    %else
        mov rax,%1
        lxd %2,rax
        xor rax,__1
        mov %3,rax
    %endif
%endmacro

; not(src,dest)
%macro not 1-2
    %if %0 == 1
        not %1
        %exitmacro
    %endif

    %if size(%2) == 1
        mov al,%1
        not al
        mov %2,al
    %elif size(%2) == 2
        mov ax,%1
        not ax
        mov %2,ax
    %elif size(%2) == 4
        mov eax,%1
        not eax
        mov %2,eax
    %else
        mov rax,%1
        not rax
        mov %2,rax
    %endif
%endmacro

; sal(src,count,dest) arithmetic shift left
%macro sal 2-3
    %if %0 == 2
        sal %1,%2
        %exitmacro
    %endif

    %if size(%3) == 1
        mov al,%1
        mov cl,%2
        sal al,cl
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        mov cl,%2
        sal ax,cl
        mov %3,ax
    %elif size(%3) == 4
        mov eax,%1
        mov cl,%2
        sal eax,cl
        mov %3,eax
    %else
        mov rax,%1
        mov cl,%2
        sal rax,cl
        mov %3,rax
    %endif
%endmacro

; sar(src,count,dest) arithmetic shift right
%macro sar 2-3
    %if %0 == 2
        sar %1,%2
        %exitmacro
    %endif

    isInputUnsigned %1,%2,%3
    %if __1
        %xdefine %%instr shr
    %else
        %xdefine %%instr sar
    %endif

    %if size(%3) == 1
        mov al,%1
        mov cl,%2
        %%instr al,cl
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        mov cl,%2
        %%instr ax,cl
        mov %3,ax
    %elif size(%3) == 4
        mov eax,%1
        mov cl,%2
        %%instr eax,cl
        mov %3,eax
    %else
        mov rax,%1
        mov cl,%2
        %%instr rax,cl
        mov %3,rax
    %endif
%endmacro