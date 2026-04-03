func abs(qword x)>1
    hold rax
    mov rax,x
    test rax,rax
    jns .pos
    neg rax
    .pos:
    return rax
end

func fabs(.qword x)>1
    hold rax,rbx
    mov rax,x
    mov rbx,7FFFFFFFFFFFFFFFh
    and rax,rbx
    mov xmm0,rax
    return rax
end

func sqrt(.qword x)>1
    hold xmm0
    mov xmm0,x
    sqrtsd xmm0,xmm0
    return xmm0
end

func floor(.qword x)>1
    hold xmm0
    mov xmm0,x
    roundsd xmm0,xmm0,1
    return xmm0
end

func ceil(.qword x)>1
    hold xmm0
    mov xmm0,x
    roundsd xmm0,xmm0,2
    return xmm0
end