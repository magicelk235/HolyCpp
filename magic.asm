.386
IDEAL
MODEL small
STACK 100h

DATASEG
lineSize equ 256

fileHandle dw ?
main db "main.mgk",0
bufferIndex dw 0

buffer db lineSize dup(?)
lines dw 2048 dup(0)
CODESEG


returnFalse:
push ax
mov ax,1234h
cmp al,ah
pop ax
ret

returnTrue:
cmp al,al
ret


proc cmpLists ; bx = offset list/str one,si = offset list/str two ; must end with a $
	cmpListsPart:
	push ax
	mov al,[bx]
	cmp al,[si]
	pop ax
	jnz returnFalse
	
	cmp [byte ptr bx],"$"
	jz returnTrue
	cmp [byte ptr si],"$"
	jz returnTrue

	inc bx
	inc si
	jmp cmpListsPart
endp cmpLists



proc openMain
	mov ax,0
	mov ah,3dh
	mov dx,offset main
	int 21h
	mov [fileHandle],ax
	ret
endp openMain

proc movePointer
	mov ah,42h
	mov al,0
	mov bx,[fileHandle]
	mov 

proc loadLines ; load evvery lie offset
    movePointer:
	mov ah, 42h
	mov al,0
	mov bx,[fileHandle]
	mov cx,0
	mov dx,[bufferIndex]
	int 21h



endp loadLines



endp loadLines

proc getLine ; cx = line index

	mov ah,3fh
	mov al,


	mov bx,[fileHandle]
	
	mov dx,offset buffer
	int 21h
	ret
endp getLine

start:
	mov ax, @data
	mov ds, ax

call openMain
call readline



exit:
	mov ax, 4c00h
	int 21h
END start