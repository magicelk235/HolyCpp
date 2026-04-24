%use ifunc
; add(var1,var2,dest)
%macro add 2-3
    %ifidn %2,0
        %exitmacro
    %endif

    %if %0 == 2
        add %1,%2
        %exitmacro
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
    %ifidn %2,0
        %exitmacro
    %endif

    %if %0 == 2
        sub %1,%2
        %exitmacro
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
        sub ax,__1
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
%macro mul 1-3
    %if %0==1
        mul %1
        %exitmacro
    %endif

    %if (%isnum(%2))
        %if %2>0 && ((%2&(%2-1))==0)
            sal %1,%eval(ilog2(%2)),%3     
            %exitmacro   
        %endif
    %endif

    isInputUnsigned %1,%2,%3
    %if __1
        %xdefine %%instr mul
    %else
        %xdefine %%instr imul
    %endif
    
    isInputFloat %1,%2,%3
    %if __1
        mov xmm0,%1
        mov xmm1,%2
        mulsd xmm0,xmm1
        mov %3,xmm0
    %elif size(%3) == 1
        mov al,%1
        lxd %2,al
        %%instr byte __1
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        %%instr ax,__1
        mov %3,ax
    %elif size(%3) == 4
        mov eax,%1
        lxd %2,eax
        %%instr eax,__1
        mov %3,eax
    %else
        mov rax,%1
        lxd %2,rax
        %%instr rax,__1
        mov %3,rax
    %endif
%endmacro

; div(var1,var2,dest)
%macro div 1-3
    %if %0==1
        div %1
        %exitmacro
    %endif

    isInputUnsigned %1,%2,%3
    %if __1
        %xdefine %%instr div
    %else
        %xdefine %%instr idiv
    %endif

    %if (%isnum(%2))
        %if %2>0 && ((%2&(%2-1))==0)
            sar %1,%eval(ilog2(%2)),%3
        %endif
    %endif

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
        %if %isnum(%2)
            mov bl,%2
            %%instr bl
        %else
            %%instr byte __1
        %endif
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        cwd
        lxd %2,ax
        %if %isnum(%2)
            mov bx,%2
            %%instr bx
        %else
            %%instr word __1
        %endif
        mov %3,ax
    %elif size(%3)==4
        mov eax,%1
        cdq
        lxd %2,eax
        %if %isnum(%2)
            mov ebx,%2
            %%instr ebx
        %else
            %%instr dword __1
        %endif
        mov %3,eax
    %else
        mov rax,%1
        cqo
        lxd %2,rax
        %if %isnum(%2)
            mov rbx,%2
            %%instr rbx
        %else
            %%instr qword __1
        %endif
        mov %3,rax
    %endif
%endmacro

; div(var1,var2,dest)
%macro mod 3
    isInputUnsigned %1,%2,%3
    %if __1
        %xdefine %%instr div
    %else
        %xdefine %%instr idiv
    %endif
    %if size(%3) == 1
        mov al,%1
        cbw 
        lxd %2,al
        %if %isnum(%2)
            mov bl,%2
            %%instr bl
        %else
            %%instr byte __1
        %endif
            
        cmp ah,0
        jge %%byteIsPos
        add ah,__1
        %%byteIsPos:
        mov %3,ah
    %elif size(%3) == 2
        mov ax,%1
        cwd
        lxd %2,ax
        %if %isnum(%2)
            mov bx,%2
            %%instr bx
        %else
            %%instr word __1
        %endif
    
        cmp dx,0
        jge %%wordIsPos
        add dx,__1
        %%wordIsPos:
        mov %3,dx
    %elif size(%3)==4
        mov eax,%1
        cdq
        lxd %2,eax
        %if %isnum(%2)
            mov ebx,%2
            %%instr ebx
        %else
            %%instr dword __1
        %endif
            
        cmp edx,0
        jge %%bwordIsPos
        add edx,__1
        %%bwordIsPos:
        mov %3,edx
    %else
        mov rax,%1
        cqo
        lxd %2,rax
        %if %isnum(%2)
            mov rbx,%2
            %%instr rbx
        %else
            %%instr qword __1
        %endif
            
        cmp rdx,0
        jge %%qwordIsPos
        add rdx,__1
        %%qwordIsPos:
        mov %3,rdx
    %endif
%endmacro

; neg(src,?dest)
%macro neg 1-2
    %if %0 == 1
        neg %1
        %exitmacro
    %endif

    isInputFloat %1,%2
    %if __1
        mov xmm0,%1
        pxor xmm1,xmm1
        subsd xmm1,xmm0
        mov %2,xmm1
    %elif size(%2) == 1
        mov al,%1
        neg al
        mov %2,al
    %elif size(%2) == 2
        mov ax,%1
        neg ax
        mov %2,ax
    %elif size(%2) == 4
        mov eax,%1
        neg eax
        mov %2,eax
    %else
        mov rax,%1
        neg rax
        mov %2,rax
    %endif
%endmacro

; power(var1,var2,dest)
%macro power 3
    mov rcx,%2 ; times
    isInputFloat %1,%2,%3
    %if __1
        %ifidn __included_lib_math__hcpp,1
            callp pow,%1,%2,%3
        %else
        mov xmm0,%1
        mov xmm1,1.0

        cmp rcx,0
        je %%powFLoopExit

        %%powFLoop:
        mulsd xmm1,xmm0
        dec rcx
        jnz %%powFLoop
        %%powFLoopExit:
        mov %3,xmm1
        %endif
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

%macro inc 1-2
    %if %0==1
        inc %1
        %exitmacro
    %endif
    isInputFloat %1,%2
    %if __1
        mov rax,1.0
        mov xmm1,rax
        mov xmm0,%1
        addsd xmm1,xmm0
        mov %2,xmm1
    %elif size(%2) == 1
        mov al,%1
        inc al
        mov %2,al
    %elif size(%2) == 2
        mov ax,%1
        inc ax
        mov %2,ax
    %elif size(%2) == 4
        mov eax,%1
        inc eax
        mov %2,eax
    %else
        mov rax,%1
        inc rax
        mov %2,rax
    %endif
%endmacro

%macro dec 1-2
    %if %0==1
        dec %1
        %exitmacro
    %endif
    isInputFloat %1,%2
    %if __1
        mov rax,1.0
        mov xmm1,rax
        mov xmm0,%1
        subsd xmm0,xmm1
        mov %2,xmm0
    %elif size(%2) == 1
        mov al,%1
        dec al
        mov %2,al
    %elif size(%2) == 2
        mov ax,%1
        dec ax
        mov %2,ax
    %elif size(%2) == 4
        mov eax,%1
        dec eax
        mov %2,eax
    %else
        mov rax,%1
        dec rax
        mov %2,rax
    %endif
%endmacro