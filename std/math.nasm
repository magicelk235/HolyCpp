; add(var1,var2,distination)
%macro add 2-3
    %if %0 == 2
        add %1,%2
    %endif

    %ifidn float(%1),1
        mov xmm0,%1
        mov xmm1,%2
        addsd xmm0,xmm1
        mov %3,xmm0
    %elif size(%3) == 1
        mov al,%1
        lxd %2,al
        add al,__1
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        add ax,__1
        mov %3,ax
    %elif size(%3)==4
        mov eax,%1
        lxd %2,eax
        add eax,__1
        mov %3,eax
    %else
        mov rax,%1
        lxd %2,rax
        add rax,__1
        mov %3,rax
    %endif
%endmacro
; subp(var1,var2,distination)
%macro sub 2-3
    %if %0 == 2
        sub %1,%2
    %endif
    %ifidn float(%1),1
        mov xmm0,%1
        mov xmm1,%2
        subsd xmm0,xmm1
        mov %3,xmm0
    %elif size(%3) == 1
        mov al,%1
        lxd %2,al
        sub al,__1
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        add ax,__1
        mov %3,ax
    %elif size(%3)==4
        mov eax,%1
        lxd %2,eax
        sub eax,__1
        mov %3,eax
    %else
        mov rax,%1
        lxd %2,rax
        sub rax,__1
        mov %3,rax
    %endif
%endmacro

; mul(var1,var2,distination)
%macro mul 3
    %ifidn float(%1),1
        mov xmm0,%1
        mov xmm1,%2
        mulsd xmm0,xmm1
        mov %3,xmm0
    %elif size(%3) == 1
        mov al,%1
        lxd %2,al
        imul byte __1
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        lxd %2,ax
        imul ax,__1
        mov %3,ax
    %elif size(%3) == 4
        mov eax,%1
        lxd %2,eax
        imul eax,__1
        mov %3,eax
    %else
        mov rax,%1
        lxd %2,rax
        imul rax,__1
        mov %3,rax
    %endif
%endmacro

; div(var1,var2,distination)
%macro div 3
    %ifidn float(%1),1
        mov xmm0,%1
        mov xmm1,%2
        divsd xmm0,xmm1
        mov %3,xmm0
    %elif size(%3) == 1
        mov al,%1
        cbw 
        lxd %2,al
        idiv byte __1
        mov %3,al
    %elif size(%3) == 2
        mov ax,%1
        cwd
        lxd %2,ax
        idiv word __1
        mov %3,ax
    %elif size(%3)==4
        mov eax,%1
        cdq
        lxd %2,eax
        idiv dword __1
        mov %3,eax
    %else
        mov rax,%1
        cqo
        lxd %2,rax
        idiv qword __1
        mov %3,rax
    %endif
%endmacro

; div(var1,var2,distination)
%macro mod 3
    %if size(%3) == 1
        mov al,%1
        cbw 
        lxd %2,al
        idiv byte __1
            
        cmp ah,0
        jge %%byteIsPos
        add ah,%1,ah
        %%byteIsPos:
        mov %3,ah
    %elif size(%3) == 2
        mov ax,%1
        cwd
        lxd %2,ax
        idiv word __1
    
        cmp dx,0
        jge %%wordIsPos
        add dx,%1,dx
        %%wordIsPos:
        mov %3,dx
    %elif size(%3)==4
        mov eax,%1
        cdq
        lxd %2,eax
        idiv dword __1
            
        cmp edx,0
        jge %%bwordIsPos
        add edx,%1,edx
        %%bwordIsPos:
        mov %3,edx
    %else
        mov rax,%1
        cqo
        lxd %2,rax
        idiv qword __1
            
        cmp rdx,0
        jge %%qwordIsPos
        add rdx,%1,rdx
        %%qwordIsPos:
        mov %3,rdx
    %endif
%endmacro

; checks if a token is operator
; isOperator(token)
%macro isOperator 1
    %ifidn %1,+
        retm 1
        %exitmacro
    %endif

    %ifidn %1,-
        retm 1
        %exitmacro
    %endif

    %ifidn %1,*
        retm 1
        %exitmacro
    %endif

    %ifidn %1,/
        retm 1
        %exitmacro
    %endif

    %ifidn %1,[
        retm 1
        %exitmacro
    %endif

    %ifidn %1,]
        retm 1
        %exitmacro
    %endif

    retm 0
%endmacro 

; get2operands(token,operatorIndex,?operatorSize)-> lhs,rhs,expression
%macro get2operands 2-3
    %if %0==2
        %assign %%size 1
    %else
        %assign %%size %3
    %endif


    tokenLen %1
    %assign %%max __1
    %assign %%min 0

    ; %assign %%start 0
    ; %assign %%stop 0

    
    %assign %%i %2-%%size
    %rep 100000
        subToken %1,%%i,%eval(%%i+1)
        %xdefine %%lhs __1
        isOperator %%lhs
        %if __1
            %assign %%start %%i+1
            %exitrep
        %elif %%i==%%min
            %assign %%start %%i
            %exitrep
        %endif
        %assign %%i %%i-1
    %endrep


    %assign %%i %2+%%size+1
    %rep 100000
        subToken %1,%eval(%%i-1),%%i
        %xdefine %%rhs __1
        isOperator %%rhs
        %if __1
            %assign %%stop %%i-1
            %exitrep
        %elif %%i==%%max
            %assign %%stop %%i
            %exitrep
        %endif

        %assign %%i %%i+1
    %endrep


    subToken %1,%%start,%%stop
    %xdefine %%expression __1
    

    subToken %1,%%start,%2
    %xdefine %%lhs __1
    subToken %1,%eval(%%size + %2),%%stop
    %xdefine %%rhs __1


    retm %%lhs,%%rhs,%%expression
%endmacro

; evalOperator(mainToken,operator,operatorMacro)
%macro evalOperator 3
    tokenLen %2
    %assign %%operatorLen __1

    %xdefine %%expression %1

    %rep 100000
        findInToken %%expression,%2
        %if __1 == -1
            %exitrep
        %endif

        get2operands %%expression,__1,%%operatorLen

        %xdefine %%operator1 __1
        %xdefine %%operator2 __2

        %xdefine %%varName exptempvar %+ varCount
        

        newt %%varName,8


        %3 %%operator1,%%operator2,%%varName
        replaceToken %%expression,__3,%%varName
        %xdefine %%expression __1
        %assign varCount varCount+1
    %endrep
    retm %%expression
%endmacro

; x-3*(x-4),(,),1
; expression,openChar,closeChar,replace
%macro searchGroup 4
    findPare %1,%2,%3

    %ifidn __1,-1
        retm -1
        %exitmacro
    %endif

    %assign %%startIndex __1+1
    %assign %%endIndex __2

    subToken %1,%%startIndex,%%endIndex
    %xdefine %%expression __1

    %if %4
        subToken %1,%eval(%%startIndex-1),%eval(%%endIndex+1)
        %define %%original __1
    %else
        %define %%original %%expression
    %endif

    retm %%original,%%expression
%endmacro

%macro eval 1

    
    %define %%expression %1
    %assign varCount 0
    %assign %%recursiveCount 1
    resetTemp

    %push
    %xdefine %$expression %%expression
    %xdefine %$original %%expression
    %rep 100000
        searchGroup %$expression,(,),1
        %ifidn __1,-1
            evalOperator %$expression, * ,mul
            %xdefine %$expression __1

            evalOperator %$expression, / ,div
            %xdefine %$expression __1

            evalOperator %$expression, % ,mod
            %xdefine %$expression __1
    
            evalOperator %$expression, - ,sub
            %xdefine %$expression __1

            evalOperator %$expression, + ,add
            %xdefine %$expression __1


            %assign %%recursiveCount %%recursiveCount-1
            %if %%recursiveCount == 0
                %xdefine %%expression %$expression    
                %exitrep
            %endif


            %xdefine __1 %$original
            %xdefine __2 %$expression
            %pop
            replaceToken %$expression,__1,__2
            %xdefine %$expression __1

        %else
            %push
            %xdefine %$original __1
            %xdefine %$expression __2
            %assign %%recursiveCount %%recursiveCount+1
        
        %endif
    %endrep
    %pop

    retm %%expression
%endmacro