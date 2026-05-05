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
; .neg *
; .inc *
; .dec *
; .bnot *
; .bor *
; .bxor *
; .band *
; .not *
; .or *
; .xor *
; .and *
; .shr *
; .shl *

%use ifunc

%define __int.set mov


newType int8,1,1
newType int16,2,1
newType int32,4,1
newType int64,8,1
newType int,4,1

; cmp(var1,var2,?dest)
%macro __int.cmp 3
    %if size(%3) == 1
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

%macro __int.equ 3
    cmp %1,%2,%3
    sete al
    mov %3,al
%endmacro

%macro __int.nequ 3
    cmp %1,%2,%3
    setne al
    mov %3,al
%endmacro

%macro __int.low 3
    __int.cmp %1,%2,%3
    setl al
    mov %3,al 
%endmacro

%macro __int.high 3
    __int.cmp %1,%2,%3
    setg al
    mov %3,al 
%endmacro

%macro __int.lequ 3
    __int.cmp %1,%2,%3
    setle al
    mov %3,al 
%endmacro

%macro __int.hequ 3
    __int.cmp %1,%2,%3
    setge al
    mov %3,al
%endmacro

%macro __int.add 3
    %if size(%3) == 1
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

%macro __int.sub 3
    %ifidn %2,0
        %exitmacro
    %endif

    %if size(%3) == 1
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

%macro __int.mul 3
    %if (%isnum(%2))
        %if %2>0 && isPow2(%2)
            sal %1,%eval(ilog2(%2)),%3     
            %exitmacro   
        %endif
    %endif

    %if (%isnum(%1))
        %if %1>0 && isPow2(%2)
            sal %2,%eval(ilog2(%1)),%3     
            %exitmacro
        %endif
    %endif

    %if size(%3) == 1
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
%macro __int.div 3
    %if (%isnum(%2))
        %if %2>0 && isPow2(%2)
            sar %1,%eval(ilog2(%2)),%3
        %endif
    %endif

    %if size(%3) == 1
        mov al,%1
        cbw
        lxd %2,al
        %if %isnum(%2)
            mov bl,%2
            idiv bl
        %else
            idiv byte __1
        %endif
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        cwd
        lxd %2,ax
        %if %isnum(%2)
            mov bx,%2
            idiv bx
        %else
            idiv word __1
        %endif
        mov %3,ax
    %elif size(%3)==4
        mov eax,%1
        cdq
        lxd %2,eax
        %if %isnum(%2)
            mov ebx,%2
            idiv ebx
        %else
            idiv dword __1
        %endif
        mov %3,eax
    %else
        mov rax,%1
        cqo
        lxd %2,rax
        %if %isnum(%2)
            mov rbx,%2
            idiv rbx
        %else
            idiv qword __1
        %endif
        mov %3,rax
    %endif
%endmacro

; neg(src,?dest)
%macro __int.neg 1-2
    %if size(%2) == 1
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

; pow(var1,var2,dest)
%macro __int.pow 3
    mov rcx,%2 ; times
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
%endmacro

%macro __int.inc 2
    %if size(%2) == 1
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

%macro __int.dec 1-2
    %if size(%2) == 1
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

; xor(src1,src2,dest)
%macro __int.xor 3
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
%macro __int.not 2
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

; shl(src,count,dest) shift left
%macro __int.shl 3

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

; shr(src,count,dest) shift right
%macro __int.shr 3

    %if size(%3) == 1
        mov al,%1
        mov cl,%2
        sar al,cl
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        mov cl,%2
        sar ax,cl
        mov %3,ax
    %elif size(%3) == 4
        mov eax,%1
        mov cl,%2
        sar eax,cl
        mov %3,eax
    %else
        mov rax,%1
        mov cl,%2
        sar rax,cl
        mov %3,rax
    %endif
%endmacro


; and(src1,src2,dest)
%macro __int.and 3
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
%macro __int.or 3
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

%define __int.bnot __bool.bnot
%define __int.bor __bool.bor
%define __int.bxor __bool.bxor
%define __int.band __bool.band

%macro __int.mod 3
    %if size(%3) == 1
        mov al,%1
        cbw
        lxd %2,al
        %if %isnum(%2)
            mov bl,%2
            idiv bl
        %else
            idiv byte __1
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
            idiv bx
        %else
            idiv word __1
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
            idiv ebx
        %else
            idiv dword __1
        %endif
        cmp edx,0
        jge %%dwordIsPos
        add edx,__1
        %%dwordIsPos:
        mov %3,edx
    %else
        mov rax,%1
        cqo
        lxd %2,rax
        %if %isnum(%2)
            mov rbx,%2
            idiv rbx
        %else
            idiv qword __1
        %endif
        cmp rdx,0
        jge %%qwordIsPos
        add rdx,__1
        %%qwordIsPos:
        mov %3,rdx
    %endif
%endmacro