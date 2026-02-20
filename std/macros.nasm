;defines a reg that isnt used as r
;resr(?size-1,used-regs-1-*)
%macro resr 0-*
    %assign %%group 0
    %define %%foundReg 0
    %define %%sizeUsed 0
    

    findInToken %1,s:
    %if __0 != -1
        subToken %1,__0+2,-1
        %define %%size __0
        %define %%sizeUsed 1
    %else
        %define %%size 8
    %endif

    %rep group(r15)+1
        %rotate %%sizeUsed
        %define %%foundReg 1
        %rep %0-%%sizeUsed
            %ifnum group(%1)
                %if group(%1) = %%group
                    %define %%foundReg 0
                %endif
            %endif
            %rotate 1
        %endrep

        %if %%foundReg == 1
           %define r reg(%%size,%%group)
           %exitrep
        %endif
        %assign %%group %%group+1
    %endrep
%endmacro

;defines a reg that isnt used as r and pushes it
;resrp(?size-1,used-regs-1-*)
%macro resrp 0-*
    resr %{1:-1}
    push r
%endmacro

; returns values from a macro to __0 ... __N
; retm(outs)
%macro retm 1-*
    %assign %%i 0
    %rep %0
        %xdefine %%index %%i
        %xdefine __%[%%i] %1
        %rotate 1
        %assign %%i %%i+1
    %endrep
%endmacro

; findInToken(token1,token2)->index
%macro findInToken 2
    %defstr %%str1 %1
    %defstr %%str2 %2

    %strlen %%lenStr1 %%str1
    %strlen %%lenStr2 %%str2
    %define %%sub ''
    %assign %%i 1
    retm -1
    %rep %%lenStr1-%%lenStr2+1
        %substr %%sub %%str1 %%i,%%lenStr2
        %ifidni %%sub,%%str2
            retm %eval(%%i-1)
            %exitrep
        %endif
        %assign %%i %%i+1
    %endrep
%endmacro

; subToken(token,start,stop?)->subtoken
%macro subToken 2-3
    %defstr %%str %1
    %if %0=2
        %assign %%stop -1
    %elif %3>0
        %assign %%stop %3-%2
    %else
        %assign %%stop %3
    %endif

    %assign %%start %2+1

    %substr %%str %%str %%start,%%stop
    %strlen %%len %%str
    %if %%len>0
        %deftok %%str %%str
        retm %%str
    %else
        retm **empty**
    %endif
%endmacro

%macro isTokenEmpty 1
    %ifidn %1,**empty**
        retm 1
    %else
        retm 0
    %endif
%endmacro

; checks if a token is a float number
%macro isTokenFloat 1
    findInToken %1 , .
    %if __0=-1
        retm 0
        %exitmacro
    %endif
    %xdefine %%dotIndex __0

    ; checks if x is a number in x.y
    subToken %1,0,%%dotIndex
    %ifnum __0
    %else
        retm 0
        %exitmacro
    %endif

    ; checks if y is a number in x.y
    subToken %1,%%dotIndex+1
    %ifnum __0
    %else
        retm 0
        %exitmacro
    %endif

    retm 1
%endmacro

; isTokenNum(token)->t/f, type int=0,float=1
%macro isTokenNum 1
    %ifnum %1
        retm 1,0
    %else
        isTokenFloat %1
        %if  __0=1
            retm 1,1
        %else
            retm 0,0
        %endif
    %endif    
%endmacro

%macro tokenLen 1
    %defstr %%str %1
    %strlen %%len %%str
    retm %%len
%endmacro

; converts a token to a number and return the type(0=int,1=float)
;TokenToNum(token)
%macro TokenToNum 1
    isTokenNum %1
    %if __0 == 1 && __1 == 1
        retm %eval(__float64__(%1)),__1
    %else
        retm %1,__1
    %endif
%endmacro

; check if a number is in a current byte size
; isNumInSize(num,size)
%macro isNumInSize 2
    %assign %%sizeInBits %2*8 -2
    %assign %%max (2<<%%sizeInBits)-1
    retm %eval((-%%max <= %1 && %1 <= %%max ? 1 : 0))
%endmacro

;replaceToken(original,old,new,times?)
%macro replaceToken 3-4
    %if %0==4
        %xdefine %%replaceTimes %4
    %else
        %define %%replaceTimes 10000
    %endif

    tokenLen %2
    %assign %%skip __0

    %xdefine %%newToken %1
    %rep %%replaceTimes
    findInToken %%newToken,%2
    %if __0 == -1
        %exitrep
    %endif   

    %assign %%index __0
    subToken %%newToken,0,%%index
    %xdefine %%leftPart __0
    

    subToken %%newToken,%eval(%%index+%%skip),-1
    %xdefine %%rightPart __0



    isTokenEmpty %%rightPart
    %if __0
        %xdefine %%newToken %%leftPart%+%3
    %else
        isTokenEmpty %%leftPart
        %if __0
            %xdefine %%newToken %3%+%%rightPart
        %else
            %xdefine %%newToken %%leftPart%+%3%+%%rightPart
        %endif
    %endif
    
    

    %endrep
    retm %%newToken
%endmacro