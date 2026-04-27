%include "std/std.nasm"
include <io>
include <process>

section .text
global _start
_start:

    new const byte exePath[] = "./exe"

    new const byte hcppPath[] = "./hcpp"
    new const byte hcppArg0[] = "hcpp"

    new const byte runCodeMessage[] = "Run Code[y/n]?\n"
    new byte sourcePath[255]
    new const byte pathInputMessage[] = "Enter The Path For Your Code:\n"
    new const byte startMessage[] = "Welcome To HolyC++ Compiler\nPress I For Instructions,Press Q To Quit,Press Enter To Compile\n"
    new const byte instructions[] = "To Compile HolyC++ Code Provide The Path To The File That Contains The Code\n"
    new const byte endMessage[] ="https://github.com/magicelk235\n"

    mov rax,@startMessage
    callp print,rax

    callp scanf,"c",al
    cmp al,10
    je .compile

    cmp byte al,"i"
    jne .notI
    mov rax,@instructions
    callp print,rax
    callp scanf,"c",al
    jmp _start ; returns to start

    .notI:
    cmp byte al,"q"
    jne _start
    mov rax,@endMessage
    callp print,rax
    jmp .exit

    .compile:
    mov rax,@pathInputMessage
    callp print,rax

    mov rax,@sourcePath
    callp scan,rax

    
    mov rcx,@hcppPath
    mov rbx,@hcppArg0

    callp run,rcx,rbx,rax,r15

    cmp r15,0
    jne _start

    mov rax,@runCodeMessage
    callp print,rax

    callp scanf,"c",al
    cmp al,"y"
    jne _start

    mov rax,@exePath

    callp run,rax,rax

    jmp _start

    
.exit:
    mov rax,60
    xor rdi,rdi
    syscall