section .text
%include "std/var.nasm"
%include "std/macros.nasm"
%include "std/proc.nasm"

; new global 8 bytes variable 
newg x,8

; new proc named function with one output
proc function,1
    ; defines two args
    arg var1,8 ; 8 bytes
    arg var2,4 ; 4 bytes
    
    ; new local 8 bytes variable
    news var3,8
    mov rax,var2
    mov var3,10.3

    ; returns rax
    retp rax
endp 


global _start
_start:
    

    call function,5,4,x

    mov rax, 60
    xor rdi, rdi
    syscall