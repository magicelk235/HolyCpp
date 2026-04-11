func malloc(qword size)>1
    hold rax
    callp mmap,"a",-1,size,rax
    return rax
end

func free(@qword ptr:qword size)
    hold rax,rdi,rsi
    mov rax,11
    mov rdi,@ptr
    mov rsi,size
    syscall
end