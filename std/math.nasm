; imul(var1,var2,distination)
%macro imul 3
    %if float(%1)
        mov xmm0,%1
        mov xmm1,%2
        mulsd xmm0,xmm1
        mov %3,xmm0
    %else
        %if size(%1) == 1
            mov al,%1
            mov dl,%2
            imul dl
            mov %3,al
        %elif size(%1) == 2
            mov ax,%1
            mov dx,%2
            imul ax,dx
            mov %3,ax
        %elif size(%1) == 4
            mov eax,%1
            mov edx,%2
            imul eax,edx
            mov %3,eax
        %else
            mov rax,%1
            mov rdx,%2
            imul rax,rdx
            mov %3,rax
        %endif
    %endif
%endmacro

; var1,var2,distination
%macro idiv 3
    %if float(%1)
        mov xmm0,%1
        mov xmm1,%2
        divsd xmm0,xmm1
        mov %3,xmm0
    %else
        %if size(%3) == 1
            mov al,%1
            cbw 
            mov bl,%2
            idiv bl
            mov %3,al
        %elif size(%3) == 2
            mov ax,%1
            cwd
            mov bx,%2
            idiv bx
            mov %3,ax
        %elif size(%3)==4
            mov eax,%1
            cdq
            mov ebx,%2
            idiv ebx
            mov %3,eax
        %else
            mov rax,%1
            cqo
            mov rbx,%2
            idiv rbx
            mov %3,rax
        %endif
    %endif
%endmacro
