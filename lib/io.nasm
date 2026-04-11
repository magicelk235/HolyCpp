func exit(qword code)
    hold rdi,rax
    mov rax,60
    mov rdi,code
    syscall
end

func close(qword fd)
    hold rax,rdi
    mov rax,3
    mov rdi,fd
    syscall
end

func open(@byte path: qword flags)>1
    hold rax,rdi,rsi,rdx,rcx
    cmp word [addr(flags)],"r"
    jne .notR
    xor rsi,rsi ; rd only
    jmp .opencall

    .notR:
    cmp word [addr(flags)],"w"
    jne .notW
    mov rsi,241h
    mov rdx,1b6h
    jmp .opencall

    .notW:
    cmp word [addr(flags)],"a"
    jne .notA
    mov rsi,441h
    mov rdx,1b6h
    jmp .opencall

    .notA:
    cmp word [addr(flags)],"r+"
    jne .notRP
    mov rsi,2
    jmp .opencall

    .notRP:
    cmp word [addr(flags)],"w+"
    jne .notWP
    mov rsi,242h
    mov rdx,1b6h
    jmp .opencall

    .notWP:
    cmp word [addr(flags)],"a+"
    jne .notAP
    mov rsi,442h
    mov rdx,1b6h
    jmp .opencall

    .notAP:
    return 0

    .opencall:
    mov rdi,@path
    add rdi,arraySizeOffset
    mov rax,2
    syscall
    return rax
end

func read(qword fd: @byte buf: qword count)
    hold rax,rdi,rsi,rdx,r15,rcx
    new byte tempBuf[4096]
    cmp qword [addr(count)],-2
    jne .fillBuf
    
    mov rax,8
    mov rdi,fd
    xor rsi,rsi
    mov rdx,1
    syscall ;lseek to get offset
    mov r15,rax
    mov rsi,@tempBuf
    
    callp read,fd,rsi,-1 ; fill the buffer

    callp find,rsi,10,1,rax ; find \n
    cmp rax,-1 
    jne .found
    callp find,rsi,0,1,rax ; find eof
    .found:
    inc rax
    mov [rsi],rax
    add r15,rax
    mov rdi,@buf
    callp copy,rdi,rsi

    mov rax,8
    mov rdi,fd
    mov rsi,r15
    mov rdx,0
    syscall
    return

    .fillBuf:
    cmp qword [addr(count)],-1
    jne .beforeNormalRead
    mov rdx,buf[#]
    dec rdx
    jmp .normalRead
    .beforeNormalRead:
    mov rdx,count
    .normalRead:
    xor rax,rax
    mov rdi,fd
    mov rsi,@buf
    add rsi,arraySizeOffset
    syscall
    sub rsi,arraySizeOffset
    mov [rsi],rax
    add rsi,rax
    omov byte [rsi+8],0
end

func write(qword fd: @byte buf:qword count)
    hold rax,rdi,rsi,rdx
    cmp qword [addr(count)],-1
    jne .beforeNormalWrite
    mov rdx,buf[#]
    jmp .normalWrite

    .beforeNormalWrite:
    mov rdx,count
    .normalWrite:
    mov rax,1
    mov rdi,fd
    mov rsi,@buf
    add rsi,arraySizeOffset
    syscall
end

func fstat(qword fd:byte field)>1
    hold rax,rdi,rsi
    new byte buf[144]
    mov rax,5
    mov rdi,fd
    mov rsi,@buf
    add rsi,arraySizeOffset
    syscall
    mov rsi,@buf
    add rsi,arraySizeOffset

    cmp byte [addr(field)],"s"
    jne .notS
    mov rsi,[rsi+48]
    return rsi ; size

    .notS:
    cmp byte [addr(field)],"m"
    jne .notM
    mov esi,[rsi+24]
    return esi ; mode/permission

    .notM:
    cmp byte [addr(field)],"t"
    jne .notT
    mov rsi,[rsi+88]
    return rsi
    .notT:
    return 0
end

func mmap(qword fd:byte mode)>1
    hold rax,rdi,rsi,rdx,r8,r9,r10,rcx
    mov rdi,0
    mov r9,0

    cmp qword [addr(argc)],16
    jg .customSize
    callp fstat,fd,"s",rsi ; gets the file size
    jmp .skipCustomSize

    .customSize:
    mov rsi,argv[2]

    .skipCustomSize:
    mov r8,fd
    cmp byte [addr(mode)],"r"
    jne .notR
    mov rdx,1 ; read
    mov r10,2 ; private
    jmp .callmmap

    .notR:
    cmp byte [addr(mode)],"w"
    jne .notW
    mov rdx,3 ; read|write
    mov r10,1 ; shared
    jmp .callmmap

    .notW:
    cmp byte [addr(mode)],"p"
    jne .notP
    mov rdx,3 ; read|write
    mov r10,2 ; private
    jmp .callmmap

    .notP:
    cmp byte [addr(mode)],"a"
    jne .notA
    mov r8,-1
    mov rdx,3 ; read|write
    mov r10,34 ; private|anonymous
    jmp .callmmap

    .notA:
    return 0

    .callmmap:
    mov rax,9
    syscall
    return rax
end

func ioctl(qword fd:qword request:qword offset:byte size)>1
    hold rax,rdi,rsi,rdx
    new byte buf[256]
    mov rax,16
    mov rdi,fd
    mov rsi,request
    mov rdx,@buf
    add rdx,arraySizeOffset
    syscall
    add rdx,[addr(offset)]
    
    cmp byte [addr(size)],1
    jne .notByte
    mov dl,[rdx]
    return dl

    .notByte:
    cmp byte [addr(size)],2
    jne .notWord
    mov dx,[rdx]
    return dx

    .notWord:
    cmp byte [addr(size)],4
    jne .notDword
    mov edx,[rdx]
    return edx

    .notDword:
    mov rdx,[rdx]
    return rdx
end

func print(@byte str)
    hold rdi
    mov rdi,@str
    callp write,1,rdi,-1
end

func scan(@byte buf)
    hold rdi
    mov rdi,@buf
    callp read,0,rdi,-1
    dec qword [rdi]
    add rdi,[rdi]
    mov [rdi+8],0,1
end

func printf(@byte format)
    hold rdi,rsi,rax,rcx,rbx
    new buf[4096]

    mov rbx,@buf
    mov rsi,@argv
    mov rcx,argc
    add rsi,rcx
    sub rcx,8

    mov rdi,@format

    cmp rcx,0
    je .calling
    .pushloop:
    push [rsi]
    sub rsi,8
    sub rcx,8
    jnz .pushloop

    .calling:
    callp sprintf,rdi,rbx

    mov rcx,argc
    sub rcx,8
    add rsp,rcx

    callp write,1,rbx,-1

end

func scanf(byte format)>1
    hold rax,rcx,rdi,rsi
    new byte readBuf[50]
    cmp byte [addr(format)],"s"
    je .string
    mov rsi,@readBuf

    callp scan,rsi

    callp sscanf,byte [addr(format)],rsi,rsi
    return rsi
    .string:
    mov rdi,@argv
    add rdi,16 ; skip argc and format
    mov rdi,[rdi] ; dest string pointer
    callp scan,rdi
    return 0
end