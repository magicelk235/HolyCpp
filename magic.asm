.386
IDEAL
MODEL small
STACK 100h

DATASEG

errorMessage db "Error! Check Youre Code$"

lineSize equ 40


endLine db 10,"$"
endFile db 0,"$"

sourceHandle dw ?
source db "main.mgk",0

lineIndex dw 0

bufferIndex dw 0
buffer db lineSize dup(?)
db "$"




dw -1
lines dw 2048 dup(0)

CODESEG

showError:
	mov dx,offset errorMessage
	mov ah,9h
	int 21h
	jmp exit


returnFalse:
push ax
mov ax,1234h
cmp al,ah
pop ax
ret

returnTrue:
cmp al,al
ret

proc clearBuffer
	push bx
	mov bx,offset buffer
	clearBufferLoop:
	mov [byte ptr bx],0
	inc bx
	cmp bx,offset buffer+lineSize
	jnz clearbufferloop
	pop bx
	ret
endp clearbuffer

proc cmpStr ; bx = offset list/str one,si = offset list/str two
	cmpStrPart:
	cmp [byte ptr bx],"$"
	jz returnTrue
	cmp [byte ptr si],"$"
	jz returnTrue

	push ax
	mov al,[bx] ; checks if the same
	cmp al,[si]
	pop ax

	jnz returnFalse
	
	inc bx
	inc si
	jmp cmpStrPart
	ret
endp cmpStr

proc findInStr ; bx = offset of str,si = offset of str ->,zf = found status, bx index
	push ax
	push bx
	dec bx
	findInStrLoop:
	inc bx

	cmp [byte ptr bx],"$"
	jnz skipEndFindInStr
	pop bx
	pop ax
	jmp returnfalse
	skipEndFindInStr:

	push bx
	push si

	call cmpStr

	pop si
	pop bx
	jnz findInStrLoop

	pop ax
	sub bx,ax

	pop ax
	jmp returnTrue
endp findInStr

proc getRawLineSize  ; dx = start,cx=stop -> cx = size LS(I) = EO(I)-SO(I)+1
	sub cx,dx
	inc cx
	ret
endp getRawLineSize

proc getRawLines ; dx=start,cx=stop -> line in buffer
	call clearBuffer
	call movePointer
	call getRawLineSize
	push ax
	push bx

	mov ah,03fh
	mov al,0
	mov bx,[sourceHandle] ; read file 
	mov dx,offset buffer
	int 21h

	pop bx
	pop ax

	ret
endp getRawLines

proc openSource
	mov ax,0
	mov ah,3dh
	mov dx,offset source
	int 21h
	mov [sourceHandle],ax

	call loadLines

	ret
endp openSource


proc movePointer; dx = start
	push ax
	push bx
	push cx
	push dx

	mov al,0
	mov ah,42h
	mov bx,[sourceHandle]
	mov cx,0
	int 21h

	pop dx
	pop cx
	pop bx
	pop ax
	ret
endp movePointer

proc setLineEnd ; bx=LinePlace
	mov di, offset lines
	add di,[lineindex] ; moves the pointer to the right line
	add di,[lineindex]

	mov cx,[lineindex]
	call getLineStart ; adds the start to the index
	dec bx
	add bx,dx

	mov [di],bx
	ret
endp setLineEnd

proc findAndSetOffset ; si = str offset
	mov bx,offset buffer
	call findInStr
	jnz returnfalse
	inc bx
	call setlineend
	jmp returntrue
endp findandsetoffset

proc loadLines ; load every line offset
	mov [lineIndex],-1 ; line index
	resetLineLoader:
	inc [lineindex]

	mov cx,[lineindex]
	call getLineStart
	mov cx,lineSize-1 ; stop
	add cx,dx
	call getrawlines

	mov si,offset endline
	call findandsetoffset
	jz resetLineLoader

	mov si,offset endfile
	call findandsetoffset
	jnz showerror
	ret
endp loadLines

proc getLineEnd ; cx = line Index -> cx=end      EO(I)
	
	push bx
	mov bx,offset lines
	add bx,cx
	add bx,cx
	mov cx,[bx]
	pop bx
	ret
endp getLineEnd

proc getLineStart ; cx = line Index -> dx = start. SO(I) = EO(I-1)+1
	push cx

	dec cx
	call getLineEnd
	inc cx
	mov dx,cx

	pop cx
	ret
endp getLineStart

proc getLine ; cx = line index
	call getLineStart
	call getLineEnd
	call getRawLines
	ret
endp getLine

start:
	mov ax, @data
	mov ds, ax

call openSource
mov cx,0
call getLine
mov dx,offset buffer
mov ah,9h
int 21h

exit:

	mov ah,3Eh
	mov bx, [sourcehandle]
	int 21h

	mov ax, 4c00h
	int 21h
END start