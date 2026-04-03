func wait(qword pid:byte mode)>1
    hold rax,rdi,rsi,rdx,r10
    mov rax,61
    mov rdi,pid
    mov r10,0 

    xor rsi,rsi

    cmp qword [addr(argc)],16
    jbe .modeCheck
    mov rsi,@argv
    add rsi,24
    mov rsi,[rsi]

    .modeCheck:
    cmp byte [addr(mode)],"b"
    jne .notBlock 
    xor rdx,rdx ;freeze unti child dies
    jmp .callwait

    .notBlock:
    cmp byte [addr(mode)],"n"
    jne .notNonBlock
    mov rdx,1 ; checks if child running if so rax=0
    jmp .callwait

    .notNonBlock:
    cmp byte [addr(mode)],"s"
    jne .notStop
    mov rdx,2
    jmp .callwait

    .notStop:
    return -1

    .callwait:
    syscall
    return rax
end

func run(@byte path)>1
    hold rax,rbx,rcx,rdx
    new qword exeArgv[255]
    new qword envp
    new dword exitCode

    mov rax,57
    syscall

    cmp rax,0
    je .child

    mov rbx,@exitCode
    callp wait,rax,"b",rbx,rax
    mov ebx,[rbx]
    shr rbx,8
    and rbx,0ffh
    return rbx

    .child:
    mov rdi,@exeArgv
    add rdi,8 ; skip the header

    mov rsi,@argv
    add rsi,16 ; skip argc and path

    mov rcx,argc
    sub rcx,8 ; -path(8)
    shr rcx,3 ; argc(inBytes)/8 = argc

    .loop:
    cmp rcx,0
    je .exitloop
    mov rax,[rsi]
    add rax,8 ; every ptr skips the header
    mov [rdi],rax

    add rsi,8
    add rdi,8
    dec rcx
    jmp .loop
    .exitloop:
    mov [rdi],0,8

    mov rax,59 ;exe
    mov rdi,@path
    add rdi,8 ; skip header

    mov rsi,@exeArgv
    add rsi,8 ; skip header
    mov rdx,@envp
    syscall
end