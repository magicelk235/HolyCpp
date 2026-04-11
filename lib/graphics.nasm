; opens fb and mmap it, returns an array of fb pointer,sizex,sizey
func openfb()>3
    hold rax,r15,r14,r13
    new byte path = "/dev/fb0"
    mov rax,@path
    callp open,rax,"r+",r15


    callp ioctl,r15,4600h,0,8,rax ;rdi [xres:4][yres:4]
    mov r14,eax ;xres

    shr rax,32
    mov r13,eax ; yres

    imul rax,r14 ; yres*xres*bytePerPixel(4) = total Size
    shl rax,2

    callp mmap,r15,"w",rax,rax

    callp close,r15 ; closes the fb0 after mmap and ioctl

    return rax,r14,r13

end

; opens a bmp image and mmap it
func openbmp(@byte path)>1
    hold rax,rbx
    mov rax,@path
    callp open,rax,"r",rbx ; open the image with read only
    callp mmap,rbx,"r",rax ; mmap with private read only
    callp close,rbx ; close the file
    return rax
end

; fbPtr+4*(x+y*xres)
func fbPixelOffset(@qword fb:qword x:qword y)>1
    hold rax,rbx
    mov rax,@fb


    mov rbx,[rax+16] ;xres
    imul rbx,[addr(y)] ; y*xres

    add rbx,[addr(x)] ; +x
    shl rbx,2 ; *4
    add rbx,[rax+8]
    return rbx
end

func clearScreen(@qword fb)
    hold rax,rbx
    mov rax,@fb
    mov rbx,[rax+16] ;xres
    imul rbx,[rax+24] ;yres
    mov rax,[rax+8] ; fb ptr
    .loop:
    mov [rax],0,4
    add rax,4
    dec rbx
    jnz .loop
end

func drawbmp(@qword fb:@byte bmp:qword x:qword y)
    hold rax,rbx,rcx,rdx,rdi,rsi,r15,r14
    mov rdi,@fb
    callp fbPixelOffset,rdi,x,y,r15 ; r15= fb offset

    mov rsi,@bmp
    mov rax,[rsi+18],8,4 ; const image width
    mov rbx,[rsi+22],8,4 ; image height
    mov rdx,[rdi+16] ; xres


    add rsi,70 ; skip the header

    mov r14,rbx ; saves the height
    shl rdx,2 ; xres*4
    imul rbx,rdx ;height*4*xres
    ; r15 is const
    add r15,rbx ; fb(x,y) + (height)*4*xres



    .resetLoop:
    dec r14 ; loop times = height
    jz .end
    mov rcx,rax ; width
    sub r15,rdx ; ptr - xres*4
    mov rdi,r15 ; changing fb ptr
    rep movsd
    
    jmp .resetLoop
    .end:
end

; draw a pixel
func draw(@qword fb:dword color:qword x:qword y)
    hold rax,rbx
    mov rax,@fb
    callp fbPixelOffset,rax,x,y,rax

    mov ebx,color
    mov [rax],ebx
end