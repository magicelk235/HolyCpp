func equal(@byte array1:@byte array2)>1
    hold rsi,rdi,rcx
    mov rsi,@array1
    mov rdi,[addr(array1)]
    mov rcx,[rsi]
    add rcx,8
    repe cmpsb
    jne .notEqual
    return 1
    .notEqual:
    return 0
end

func copy(@byte dest:@byte src)
    hold rsi,rdi,rcx
    mov rsi,[addr(src)]
    mov rdi,[addr(dest)]
    mov rcx,[rsi]
    add rcx,8
    rep movsb
end

func fill(@byte array:qword value:byte size)
    hold rax,rbx,rcx
    mov rcx,array[#]
    mov rbx,@array
    add rbx,8

    ; loads the value to ax by the size
    cmp byte [addr(size)],1
    jne .setword
    mov al,[addr(value)]
    jmp .loop

    .setword:
    cmp byte [addr(size)],2
    jne .setdword
    mov ax,[addr(value)]
    jmp .loop

    .setdword:
    cmp byte [addr(size)],4
    jne .setqword
    mov eax,[addr(value)]
    jmp .loop
    .setqword:
    mov rax,[addr(value)]


    .loop:

    cmp byte [addr(size)],1
    jne .word
    mov [rbx],al
    jmp .loopEnd
    .word:
    cmp byte [addr(size)],2
    jne .dword
    mov [rbx],ax
    jmp .loopEnd
    .dword:
    cmp byte [addr(size)],4
    jne .qword
    mov [rbx],eax
    jmp .loopEnd
    .qword:
    mov [rbx],rax

    .loopEnd:
    add rbx,[addr(size)]
    sub rcx,[addr(size)]
    jnz .loop
end

func count(@byte array:qword value:byte size)>1
    hold rax,rbx,rcx,rdx,r15
    ;offset array +8 skip header
    mov rbx,@array
    add rbx,8
    ; array size
    mov rcx,array[#]
    mov r15,0

    ; loads the value to ax by the size
    cmp byte [addr(size)],1
    jne .setword
    mov al,[addr(value)]
    jmp .loop
    .setword:
    cmp byte [addr(size)],2
    jne .setdword
    mov ax,[addr(value)]
    jmp .loop
    .setdword:
    cmp byte [addr(size)],4
    jne .setqword
    mov eax,[addr(value)]
    jmp .loop
    .setqword:
    mov rax,[addr(value)]

    .loop:

    cmp byte [addr(size)],1
    jne .word
    mov dl,[rbx]
    cmp dl,al
    jne .loopEnd
    inc r15
    jmp .loopEnd

    .word:
    cmp byte [addr(size)],2
    jne .dword
    mov dx,[rbx]
    cmp dx,ax
    jne .loopEnd
    inc r15
    jmp .loopEnd

    .dword:
    cmp byte [addr(size)],4
    jne .qword
    mov edx,[rbx]
    cmp edx,eax
    jne .loopEnd
    inc r15
    jmp .loopEnd
    .qword:
    mov rdx,[rbx]
    cmp rdx,rax
    jne .loopEnd
    inc r15

    .loopEnd:
    add rbx,[addr(size)]
    sub rcx,[addr(size)]
    jnz .loop
    return r15
end

func find(@byte array:qword value:byte size)>1
    hold rax,rbx,rcx,rdx,r15
    ;offset array +8 skip header
    mov rbx,@array
    add rbx,8
    ; array size
    mov rcx,array[#]
    mov r15,0

    ; loads the value to ax by the size
    cmp byte [addr(size)],1
    jne .setword
    mov al,[addr(value)]
    jmp .loop
    .setword:
    cmp byte [addr(size)],2
    jne .setdword
    mov ax,[addr(value)]
    jmp .loop
    .setdword:
    cmp byte [addr(size)],4
    jne .setqword
    mov eax,[addr(value)]
    jmp .loop
    .setqword:
    mov rax,[addr(value)]

    .loop:

    cmp byte [addr(size)],1
    jne .word
    mov dl,[rbx]
    cmp dl,al
    jne .notEqual
    return r15

    .word:
    cmp byte [addr(size)],2
    jne .dword
    mov dx,[rbx]
    cmp dx,ax
    jne .notEqual
    return r15

    .dword:
    cmp byte [addr(size)],4
    jne .qword
    mov edx,[rbx]
    cmp edx,eax
    jne .notEqual
    return r15
    .qword:
    mov rdx,[rbx]
    cmp rdx,rax
    jne .notEqual
    return r15

    .notEqual:
    inc r15
    add rbx,[addr(size)]
    sub rcx,[addr(size)]
    jnz .loop
    return -1
end

func contains(@byte array:qword value:byte size)>1
    hold rcx
    callp find,[addr(array)],value,size,rcx
    cmp rcx,-1
    je .notFound
    return 1
    .notFound:
    return 0
end