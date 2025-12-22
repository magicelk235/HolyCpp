

; moves the pointer base on a start     sourceHandle,start
proc movePointer
    push bp
    mov bp,sp
	push ax
	push bx
	push cx
	push dx

    mov bx,[bp+6] ; sourceHandle
    mov dx,[bp+4] ; start

	mov al,0
	mov ah,42h
	mov cx,0
	int 21h

	pop dx
	pop cx
	pop bx
	pop ax
    pop bp
	ret 4
endp movePointer

; fills a list      data,offset start,bytes size      
proc fillList
    push bp
    mov bp,sp
    push cx
    push dx
    push bx

    mov dx,[bp+8] ;data
    mov bx,[bp+6] ; offset start
    mov cx,[bp+4]
    add cx,dx ; size


    fillList:
    mov [bx],dl
    inc bx
    cmp bx,cx


    pop bx
    pop dx
    pop cx
    pop bp
    ret 6
endp fillList

; get size size LS(I) = EO(I)-SO(I)+1 start,stop ->
proc getRawLineSize
    push bp
    mov bp,sp
    push ax

    mov ax,[bp+4]; stop   
	sub ax,[bp+6] ; size= start-stop+1
	inc ax

    mov [bp+6],ax

    pop ax
    pop bp
	ret 2
endp getRawLineSize

; gets a line by start and end,  sourceHandle,buffer size,offset buffer,start,end
proc getLineByStartAndEnd 
    push bp
    mov bp,sp
    
    push ax
	push bx
    push dx
    push cx

    push 0
    push [bp+8] ; offset buffer
    push [bp+10] ; buffer size
    call fillList

    push [bp+12] ; sourceHandle
    push [bp+6] ; start
	call movePointer

    push [bp+6] ; start
    push [bp+4] ; end 
	call getRawLineSize
    pop cx

	mov ah,03fh
	mov al,0
	mov bx,[sourceHandle] ; read file 
	mov dx,offset buffer
	int 21h

    pop cx
    pop dx
	pop bx
	pop ax
	ret 10
endp getLineByStartAndEnd


; start
proc cmpList
    
endp cmpList


;description
proc readFile
    
endp readFile