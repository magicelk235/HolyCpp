%include "std/std.nasm"
%include "lib/lib.nasm"
section .data


section .text
global _start
_start:

    new const byte exePath[] = "./exe"

    new const byte nasmPath[] = "/usr/bin/nasm"
    new const byte nasmArg0[] = "nasm"
    new const byte nasmArg1[] = "-f"
    new const byte nasmArg2[] = "elf64"
    new const byte nasmArg3[] = "-o"
    new const byte nasmArg4[] = "exe.o"
    ; arg5 = destpath

    ;linker
    new const byte linkerPath[] = "/usr/bin/ld"
    new const byte linkerArg0[] = "ld"
    new const byte linkerArg1[] = "-o"
    new const byte linkerArg2[] = "exe"
    new const byte linkerArg3[] = "exe.o"


    new const byte successMessage[] = "Compilation Succeed\nRun Code[y/n]?\n"
    new const byte failMessage[] = "Compilation Failed\n"


    new qword sourceFD
    new qword destFD
    new byte sourcePath[255]
    new const byte destPath[] = "exe.asm"
    new byte fileBuf[32768]
    new byte inputBuf[5]
    new const byte pathInputMessage[] = "Enter The Path For Your Code:\n"
    new const byte startData[] = "\nsection .text\n%include 'std/std.nasm'\n"
    new const byte endData[] = "\nglobal _start\n_start:\ncallp main,rdi\nmov rax,60\nsyscall\n"
    new const byte startMessage[] = "Welcome To HolyC++ Compiler\nPress I For Instructions,Press Q To Quit,Press Enter To Compile\n"
    new const byte instructions[] = "To Compile HolyC++ Code Provide The Path To The File That Contains The Code\n\n"
    new const byte endMessage[] ="https://github.com/magicelk235\n"

    mov rax,@startMessage
    callp print,rax

    mov rax,@inputBuf
    callp scan,rax
    cmp byte [rax+8],0 ; scan clears \n 
    je .compile

    cmp byte [rax+8],"i"
    jne .notI
    mov rax,@instructions
    callp print,rax
    mov rax,@inputBuf
    callp scan,rax
    jmp _start ; returns to start

    .notI:
    cmp byte [rax+8],"q"
    jne _start
    mov rax,@endMessage
    callp print,rax
    jmp exit

    .compile:
    mov rax,@pathInputMessage
    callp print,rax

    mov rax,@sourcePath
    callp scan,rax
    callp open,rax,"r",sourceFD

    mov rax,@fileBuf
    callp read,sourceFD,rax,-1

    mov rax,@destPath
    callp open,rax,"w+",destFD

    mov rax,@startData
    callp write,destFD,rax,-1
    
    mov rax,@fileBuf
    callp write,destFD,rax,-1

    mov rax,@endData
    callp write,destFD,rax,-1

    callp close,destFD
    callp close,sourceFD

    mov rax,@nasmPath
    mov rbx,@nasmArg0
    mov rcx,@nasmArg1
    mov rdx,@nasmArg2
    mov rdi,@nasmArg3
    mov rsi,@nasmArg4
    mov r8,@destPath
    callp run,rax,rbx,rcx,rdx,rdi,rsi,r8,r15 ; return the exit code to r15

    cmp r15,0
    jne .failed

    mov rax,@linkerPath
    mov rbx,@linkerArg0
    mov rcx,@linkerArg1
    mov rdx,@linkerArg2
    mov rsi,@linkerArg3
    callp run,rax,rbx,rcx,rdx,rsi,rax

    mov rax,@successMessage
    callp print,rax

    mov rax,@inputBuf
    mov [rax],5,8
    callp scan,rax
    cmp byte [rax+8],"y"
    jne _start

    mov rax,@exePath

    callp run,rax,rax
    
    jmp _start


    .failed:
    mov rax,@failMessage
    callp print,rax



exit:
    mov rax,60
    xor rdi,rdi
    syscall