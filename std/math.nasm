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
        lxd %2,al
        add al,__0
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        add ax,__0
        mov %3,ax
    %elif size(%3)==4
        mov eax,%1
        lxd %2,eax
        add eax,__0
        mov %3,eax
    %else
        mov rax,%1
        lxd %2,rax
        add rax,__0
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
        subsd xmm0,xmm1
        mov %3,xmm0
    %elif size(%3) == 1
        mov al,%1
        lxd %2,al
        sub al,__0
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        add ax,__0
        mov %3,ax
    %elif size(%3)==4
        mov eax,%1
        lxd %2,eax
        sub eax,__0
        mov %3,eax
    %else
        mov rax,%1
        lxd %2,rax
        sub rax,__0
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
    %elif size(%3) == 1
        mov al,%1
        lxd %2,al
        imul byte __0
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        imul ax,__0
        mov %3,ax
    %elif size(%3) == 4
        mov eax,%1
        lxd %2,eax
        imul eax,__0
        mov %3,eax
    %else
        mov rax,%1
        lxd %2,rax
        imul rax,__0
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
        lxd %2,al
        idiv byte __0
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        cwd
        lxd %2,ax
        idiv word __0
        mov %3,ax
    %elif size(%3)==4
        mov eax,%1
        cdq
        lxd %2,eax
        idiv dword __0
        mov %3,eax
    %else
        mov rax,%1
        cqo
        lxd %2,rax
        idiv qword __0
        mov %3,rax
    %endif
%endmacro

; div(var1,var2,distination)
%macro mod 3
    %if size(%3) == 1
        mov al,%1
        cbw 
        lxd %2,al
        idiv byte __0
            
        cmp ah,0
        jge %%byteIsPos
        add ah,%1,ah
        %%byteIsPos:
        mov %3,ah
    %elif size(%3) == 2
        mov ax,%1
        cwd
        lxd %2,ax
        idiv word __0
    
        cmp dx,0
        jge %%wordIsPos
        add dx,%1,dx
        %%wordIsPos:
        mov %3,dx
    %elif size(%3)==4
        mov eax,%1
        cdq
        lxd %2,eax
        idiv dword __0
            
        cmp edx,0
        jge %%bwordIsPos
        add edx,%1,edx
        %%bwordIsPos:
        mov %3,edx
    %else
        mov rax,%1
        cqo
        lxd %2,rax
        idiv qword __0
            
        cmp rdx,0
        jge %%qwordIsPos
        add rdx,%1,rdx
        %%qwordIsPos:
        mov %3,rdx
    %endif
%endmacro