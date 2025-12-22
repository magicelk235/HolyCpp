; set var   data:4, size in byte:2s,offset:2
proc setVar
    push bp
    mov bp,sp
    push eax
    push bx
    push cx
    
    mov bx,[bp+4] ; offset data
    mov cx,[bp+6] ; size
    cmp cx,1
    jne notSize1

    mov ax,[bp+8] ; data
    mov [bx],al
    jmp endSetVar2

    notSize1:
    cmp cx,2
    jne notSize2
    
    mov ax,[bp+8] ; data
    mov [bx],ax
    jmp endSetVar2
    
    notSize2:
    mov eax,[bp+8] ; data
    mov [bx],eax


    endSetVar4:
    pop cx
    pop bx
    pop eax
    pop bp
    ret 8
    
    endSetVar2:
    pop cx
    pop bx
    pop eax
    pop bp
    ret 6
endp setVar