; x-> |x|
proc absp
    push bp
    mov bp,sp
    push eax
    mov eax,[bp+4]
    cmp eax,0
    jle alreadyPosi
    neg eax
    
    alreadyPosi:
    mov [bp+4],eax
    pop eax
    pop bp
    ret
endp absp

;x,y -> x-y
proc subp
    push bp
    mov bp,sp
    

    neg [dword ptr bp+4]
    push [dword ptr bp+4] 
    push [dword ptr bp+8]
    call addp
    pop [dword ptr bp+8]

    
    pop bp
    ret 4
endp subp

;x,y -> x+y
proc addp
    push bp
    mov bp,sp
    push eax

    mov eax,[bp+4]
    add eax,[bp+8]
    mov [bp+8],eax

    pop eax
    pop bp
    ret 4
endp addp

; x,y -> x*y
;description
proc mulp
    push bp
    mov bp,sp
    push eax
    push edx

    mov eax,[bp+4]
    mov edx,[bp+8]
    imul edx

    mov [bp+8],eax

    pop edx
    pop eax
    pop bp
    ret 4
endp mulp

;x,y -> x**y=x^y
proc powp
    push bp
    mov bp,sp
    push ecx
    push edx


    mov edx,1 ; sum of x*x..}y
    mov ecx,[bp+4] ; y times
    cmp ecx,0
    jl negPowp
    

    powLoop:
    cmp ecx,0
    je powgotcalc

    push edx
    push [dword ptr bp+8]
    call mulp
    pop edx
    

    dec ecx
    jmp powLoop

    powGotCalc:
    mov [bp+8],edx
    jmp endpowp

    negPowp: ; x^-n= 1/x^n
    neg ecx ; -n*-1=n
    push edx
    push ecx
    call powp
    pop edx ; x^n
    mov ecx,1 
    push edx
    push edx
    call divp ; 1/x^n
    pop [dword ptr bp+8]


    endPowp:

    pop edx
    pop ecx
    pop bp
    ret 4
endp powp

; x,y -> x//y
proc divp
    push bp
    mov bp,sp
    push eax
    push edx
    push ecx

    xor edx,edx

    mov eax,[bp+4]
    mov ecx,[bp+8]

    cmp eax,0
    jl eaxNotNegDivp

    mov edx,-1

    eaxNotNegDivp:

    idiv ecx

    mov [bp+8],eax    

    pop ecx
    pop edx
    pop eax
    pop bp
    ret 4
endp divp

; x,y -> x%y 
proc modp
    push bp
    mov bp,sp
    push eax
    push edx
    push ecx

    xor edx,edx
    mov eax,[bp+4]
    mov ecx,[bp+8]

    cmp eax,0
    jl eaxNotNegModp

    mov edx,-1
    eaxNotNegModp:

    idiv ecx

    cmp ecx,0
    jl ecxNotNegModp
    add ecx,[bp+4]

    ecxNotNegModp:
    mov [bp+8],edx

    pop ecx
    pop edx
    pop eax
    pop bp
    ret 4
endp modp

