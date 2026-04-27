%include "std/std.nasm"
include <io>
include <process>

section .data

section .text
global _start
_start:
    new const byte nasmPath[] = "/usr/bin/nasm"
    new const byte nasmArg0[] = "nasm"
    new const byte nasmArg1[] = "-f"
    new const byte nasmArg2[] = "elf64"
    new const byte nasmArg3[] = "-o"
    new const byte nasmArg4[] = "exe.o"
    new const byte nasmArg5[] = "exe.asm"


    new const byte linkerPath[] = "/usr/bin/ld"
    new const byte linkerArg0[] = "ld"
    new const byte linkerArg1[] = "-o"
    new const byte linkerArg2[] = "exe"
    new const byte linkerArg3[] = "exe.o"

    new const byte destPath[] = "exe.asm"
    new const byte startData[] = "\nsection .text\n%include 'std/std.nasm'\n"
    new const byte endData[] = "\nglobal _start\n_start:\nshl qword [rsp],3\ncallp main,rsp\nomov rax,60\nsyscall\n"
    new const byte failMessage[] = "Compilation Failed\n"
    new const byte successMessage[] = "Compilation Succeed\n"
    new const byte usageMessage[] = "Usage: hcpp <source>\n"


    new qword sourceFD
    new qword destFD
    new byte sourcePath[255]
    new qword filePointer
    new qword fileSize

    
    cmp qword [rsp], 2
    jne usage ;argc != 2


    xor rsi,rsi
    mov rdi,[rsp+16]
    mov rax,2
    syscall
    mov sourceFD,rax

    callp mmap,sourceFD,"r",filePointer
    callp fstat,sourceFD,"s",fileSize
    callp close,sourceFD

    mov rax,@destPath
    callp open,rax,"w+",destFD

    mov rax,@startData
    callp write,destFD,rax,-1

    mov rax,1
    mov rdi,destFD
    mov rsi,filePointer
    mov rdx,fileSize
    syscall

    mov rax,@endData
    callp write,destFD,rax,-1

    callp close,destFD

    ; run nasm
    mov rax,@nasmPath
    mov rbx,@nasmArg0
    mov rcx,@nasmArg1
    mov rdx,@nasmArg2
    mov rdi,@nasmArg3
    mov rsi,@nasmArg4
    mov r8,@nasmArg5
    callp run,rax,rbx,rcx,rdx,rdi,rsi,r8,r15

    cmp r15,0
    jne failed

    ; run linker
    mov rax,@linkerPath
    mov rbx,@linkerArg0
    mov rcx,@linkerArg1
    mov rdx,@linkerArg2
    mov rsi,@linkerArg3
    callp run,rax,rbx,rcx,rdx,rsi,rax

    mov rax,@successMessage
    callp print,rax

    omov rax,60
    xor rdi,rdi
    syscall

usage:
    mov rax,@usageMessage
    callp print,rax
    omov rax,60
    mov rdi,1
    syscall
    
failed:
    mov rax, @failMessage
    callp print,rax
    omov rax,60
    mov rdi,1
    syscall