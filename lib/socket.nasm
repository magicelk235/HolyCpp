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
    add rsi,arraySizeOffset
    mov rdx,16
    syscall
    cmp rax,0
    sete al
    mov rax,al
    return al
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
    add rsi,arraySizeOffset
    mov rdx,16
    syscall

    cmp rax,0
    sete al
    mov rax,al
    return al
end

func listen(qword socketfd:qword backlog)>1
    hold rax,rdi,rsi,rdx
    mov rax,50
    mov rdi,socketfd
    mov rsi,backlog
    syscall

    cmp rax,0
    sete al
    mov rax,al
    return al
end

func send(qword socketfd: @byte buf: qword count: byte flags)
    hold rax,rdi,rsi,rdx,r10,r8,r9
    
    cmp byte [addr(flags)],"n" ; normal
    jne .notNormal
    xor r10,r10

    .notNormal:
    cmp byte [addr(flags)],"d" ; dontwait
    jne .notDontWait
    mov r10,40h ; MSG_DONTWAIT
    jmp .call

    .notDontWait:
    return

    .call:
    cmp qword [addr(count)],-1
    jne .normalSend
    mov rdx,@buf
    mov rdx,[rdx]
    jmp .dosend

    .normalSend:
    mov rdx,count

    .dosend:
    mov rax,44
    mov rdi,socketfd
    mov rsi,@buf
    add rsi,arraySizeOffset
    xor r8,r8
    xor r9,r9
    syscall
end

func recv(qword socketfd: @byte buf: qword count: byte flags)
    hold rax,rdi,rsi,rdx,r10,r8,r9
    

    cmp byte [addr(flags)],"n" ; normal
    jne .notNormal
    xor r10,r10
    jmp .call

    .notNormal:
    cmp byte [addr(flags)],"d" ; dont wait
    jne .notDontWait
    mov r10,40h ; MSG_DONTWAIT
    jmp .call

    .notDontWait:
    cmp byte [addr(flags)],"p" ; peek
    jne .notPeek
    mov r10,2 ; MSG_PEEK
    jmp .call

    .notPeek:
    cmp byte [addr(flags)],"w" ; waitall
    jne .notWaitAll
    mov r10,100h ; MSG_WAITALL
    jmp .call

    .notWaitAll:
    return

    .call:
    cmp qword [addr(count)],-1
    jne .normalRecv
    mov rdx,@buf
    mov rdx,[rdx]
    jmp .dorecv

    .normalRecv:
    mov rdx,count

    .dorecv:
    mov rax,45
    mov rdi,socketfd
    mov rsi,@buf
    add rsi,arraySizeOffset
    xor r8,r8
    xor r9,r9
    syscall
    mov [addr(buf)],rax
end

func clientIp(qword socketfd)>1
    hold rax,rdi,rsi,rdx
    new byte client[16]
    mov rax,52
    mov rdi,socketfd
    mov rsi,@client
    mov rdx,rsi
    add rsi,arraySizeOffset
    syscall

    xor rdx,rdx ; making the rdx
    mov ebx,[rsi+4]
    mov dh,bl
    mov dl,bh
    shl edx,16

    shr ebx,16
    mov dh,bl
    mov dl,bh 

    return rdx
end

func accept(qword socketfd)>1
    hold rax,rdi,rsi,rdx
    new byte client[16]
    mov rax,43
    mov rdi,socketfd
    mov rsi,@client
    mov rdx,rsi
    add rsi,arraySizeOffset
    syscall
    return rax
end

func disconnect(qword socketfd)>1
    hold rax,rdi,rsi
    mov rsi,2 ; SHUT_RDWR
    mov rax,48
    mov rdi,socketfd
    syscall
    cmp rax,0
    sete al
    return al
end