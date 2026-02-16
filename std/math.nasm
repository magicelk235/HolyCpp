; add(var1,var2,distination)
%macro add 2-3
    %if %0 == 2
        add %1,%2
    %endif

    %ifidn float(%1),1
        mov xmm0,%1
        mov xmm1,%2
        addsd xmm0,xmm1
        mov %3,xmm0
    %elif size(%3) == 1
        mov al,%1
        mov ah,%2            
        add al,ah
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        mov bx,%2
        add ax,bx
        mov %3,ax
    %elif size(%3)==4
        mov eax,%1
        mov ebx,%2
        add eax,ebx
        mov %3,eax
    %else
        mov rax,%1
        mov rbx,%2
        add rax,rbx
        mov %3,rax
    %endif
%endmacro

; subp(var1,var2,distination)
%macro sub 2-3
    %if %0 == 2
        sub %1,%2
    %endif
    %ifidn float(%1),1
        mov xmm0,%1
        mov xmm1,%2
        subd xmm0,xmm1
        mov %3,xmm0
    %elif size(%3) == 1
        mov al,%1
        mov ah,%2            
        sub al,ah
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        mov bx,%2
        add ax,bx
        mov %3,ax
    %elif size(%3)==4
        mov eax,%1
        mov ebx,%2
        sub eax,ebx
        mov %3,eax
    %else
        mov rax,%1
        mov rbx,%2
        sub rax,rbx
        mov %3,rax
    %endif
%endmacro

; mul(var1,var2,distination)
%macro mul 3
    %ifidn float(%1),1
        mov xmm0,%1
        mov xmm1,%2
        mulsd xmm0,xmm1
        mov %3,xmm0
    %elif size(%1) == 1
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
%endmacro

; div(var1,var2,distination)
%macro div 3
    %ifidn float(%1),1
        mov xmm0,%1
        mov xmm1,%2
        divsd xmm0,xmm1
        mov %3,xmm0
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
%endmacro

; div(var1,var2,distination)
%macro mod 3
    %if size(%3) == 1
        mov al,%1
        cbw
        mov bl,%2
        idiv bl
            
        cmp ah,0
        jge %%byteIsPos
        add ah,%1,ah
        %%byteIsPos:
        mov %3,ah
    %elif size(%3) == 2
        mov ax,%1
        cwd
        mov bx,%2
        idiv bx
    
        cmp dx,0
        jge %%wordIsPos
        add dx,%1,dx
        %%wordIsPos:
        mov %3,dx
    %elif size(%3)==4
        mov eax,%1
        cdq
        mov ebx,%2
        idiv ebx
            
        cmp edx,0
        jge %%bwordIsPos
        add edx,%1,edx
        %%bwordIsPos:
        mov %3,edx
    %else
        mov rax,%1
        cqo
        mov rbx,%2
        idiv rbx
            
        cmp rdx,0
        jge %%qwordIsPos
        add rdx,%1,rdx
        %%qwordIsPos:
        mov %3,rdx
    %endif
%endmacro