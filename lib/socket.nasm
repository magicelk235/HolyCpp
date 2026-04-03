func socket(byte mode)>1
    hold rax,rdi,rsi,rdx
    mov rdx,0 ; default
    
    cmp byte [addr(mode)],"t"
    jne .notTCP
    mov rdi,2
    mov rsi,1
    jmp .call

    .notTCP:
    cmp byte [addr(mode)],"u"
    jne .notUDP
    mov rdi,2
    mov rsi,2
    jmp .call

    .notUDP:
    cmp byte [addr(mode)],"l"
    jne .notLocal
    mov rdi,1
    mov rsi,1
    jmp .call
    .notLocal:
    return -1

    .call:
    mov rax,41
    syscall
    return rax
end

func connect(qword socketfd:dword ip:word port)>1
    hold rax,rdi,rsi,rdx
    new byte server[16] = [2:0:0:0:0:0:0:0:0:0:0:0:0:0:0]
    mov rax,@server
    add rax,10 ;

    mov dx,port
    mov [rax],dh
    mov [rax+1],dl
    add rax,2

    mov edx,ip
    shr edx,16
    mov [rax],dh
    mov [rax+1],dl

    mov edx,ip
    mov [rax+2],dh
    mov [rax+3],dl

    mov rax,42
    mov rdi,socketfd
    mov rsi,@server
    add rsi,8
    mov rdx,16
    syscall
    return rax
end

func bind(qword socketfd:word port)>1
    hold rax,rdi,rsi,rdx
    new byte server[16] = [2:0:0:0:0:0:0:0:0:0:0:0:0:0:0]
    mov rax,@server
    add rax,10

    mov dx,port
    mov [rax],dh
    mov [rax+1],dl
    add rax,2

    mov rax,49
    mov rdi,socketfd
    mov rsi,@server
    add rsi,8
    mov rdx,16
    syscall
    return rax
end

func listen(qword socketfd:qword backlog)>1
    hold rax,rdi,rsi,rdx
    mov rax,50
    mov rdi,socketfd
    mov rsi,backlog
    syscall
    return rax
end

func accept(qword socketfd:@byte client)>1
    hold rax,rdi,rsi,rdx
    mov rax,43
    mov rdi,socketfd
    mov rsi,@client
    mov rdx,[rdi]
    add rsi,8
    syscall
    return rax
end