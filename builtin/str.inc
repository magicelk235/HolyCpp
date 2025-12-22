;gets a string abd copy it to an other,  offset string2,suze,offset string1
proc copyStr
    push bp
    mov bp,sp
    push bx
    push si
    push cx
    push dx
    
    mov bx,[bp+4] ; offset str 1
    mov si,[bp+8] ; offset str string2
    mov cx,[bp+6] ; str 1 size
    
    copyStrLoop:
    mov dl,[bx]
    mov [si],dl
    
    inc bx
    inc si
    
    dec cx
    jnz copyStrLoop
    
    pop dx
    pop cx
    pop si
    pop bx
    pop bp
    ret 6
endp copyStr

proc fillStr
endp fillStr