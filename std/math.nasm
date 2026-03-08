; add(var1,var2,dest)
%macro add 2-3
    %if %0 == 2
        add %1,%2
    %endif

    isInputFloat %1,%2,%3
    %if __1
        mov xmm0,%1
        mov xmm1,%2
        addsd xmm0,xmm1
        mov %3,xmm0
    %elif size(%3) == 1
        mov al,%1
        lxd %2,al
        add al,__1
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        add ax,__1
        mov %3,ax
    %elif size(%3)==4
        mov eax,%1
        lxd %2,eax
        add eax,__1
        mov %3,eax
    %else
        mov rax,%1
        lxd %2,rax
        add rax,__1
        mov %3,rax
    %endif
%endmacro
; subp(var1,var2,dest)
%macro sub 2-3
    %if %0 == 2
        sub %1,%2
    %endif

    isInputFloat %1,%2,%3
    %if __1
        mov xmm0,%1
        mov xmm1,%2
        subsd xmm0,xmm1
        mov %3,xmm0
    %elif size(%3) == 1
        mov al,%1
        lxd %2,al
        sub al,__1
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        add ax,__1
        mov %3,ax
    %elif size(%3)==4
        mov eax,%1
        lxd %2,eax
        sub eax,__1
        mov %3,eax
    %else
        mov rax,%1
        lxd %2,rax
        sub rax,__1
        mov %3,rax
    %endif
%endmacro

; mul(var1,var2,dest)
%macro mul 3
    isInputFloat %1,%2,%3
    %if __1
        mov xmm0,%1
        mov xmm1,%2
        mulsd xmm0,xmm1
        mov %3,xmm0
    %elif size(%3) == 1
        mov al,%1
        lxd %2,al
        imul byte __1
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        imul ax,__1
        mov %3,ax
    %elif size(%3) == 4
        mov eax,%1
        lxd %2,eax
        imul eax,__1
        mov %3,eax
    %else
        mov rax,%1
        lxd %2,rax
        imul rax,__1
        mov %3,rax
    %endif
%endmacro

; div(var1,var2,dest)
%macro div 3
    isInputFloat %1,%2,%3
    %if __1
        mov xmm0,%1
        mov xmm1,%2
        divsd xmm0,xmm1
        mov %3,xmm0
    %elif size(%3) == 1
        mov al,%1
        cbw 
        lxd %2,al
        idiv byte __1
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        cwd
        lxd %2,ax
        idiv word __1
        mov %3,ax
    %elif size(%3)==4
        mov eax,%1
        cdq
        lxd %2,eax
        idiv dword __1
        mov %3,eax
    %else
        mov rax,%1
        cqo
        lxd %2,rax
        idiv qword __1
        mov %3,rax
    %endif
%endmacro

; div(var1,var2,dest)
%macro mod 3
    %if size(%3) == 1
        mov al,%1
        cbw 
        lxd %2,al
        idiv byte __1
            
        cmp ah,0
        jge %%byteIsPos
        add ah,%1,ah
        %%byteIsPos:
        mov %3,ah
    %elif size(%3) == 2
        mov ax,%1
        cwd
        lxd %2,ax
        idiv word __1
    
        cmp dx,0
        jge %%wordIsPos
        add dx,%1,dx
        %%wordIsPos:
        mov %3,dx
    %elif size(%3)==4
        mov eax,%1
        cdq
        lxd %2,eax
        idiv dword __1
            
        cmp edx,0
        jge %%bwordIsPos
        add edx,%1,edx
        %%bwordIsPos:
        mov %3,edx
    %else
        mov rax,%1
        cqo
        lxd %2,rax
        idiv qword __1
            
        cmp rdx,0
        jge %%qwordIsPos
        add rdx,%1,rdx
        %%qwordIsPos:
        mov %3,rdx
    %endif
%endmacro

; pow(var1,var2,dest)
%macro pow 3
    mov rcx,%2 ; times
    isInputFloat %1,%2,%3
    %if __1
        mov xmm0,%1 ;var1
        mov xmm1,1.0

        cmp rcx,0
        je %%powLoopExit

        %%powLoop:
        mulsd xmm1,xmm0

        dec rcx
        jnz %%powLoop
        %%powLoopExit:
        mov %3,xmm1
    %else
        mov rax,%1 ; var1
        mov rdx,1

        cmp rcx,0
        je %%powLoopExit

        %%powLoop:
    
        imul rdx,rax

        dec rcx
        jnz %%powLoop
        %%powLoopExit:
        mov %3,rdx
    %endif
%endmacro