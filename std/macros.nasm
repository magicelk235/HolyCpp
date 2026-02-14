;defines a breg that isnt used
;borrowReg(?size-1,used-regs-1-*)
%macro borrowReg 0-*

    %assign %%group 0
    %define %%foundReg 0
    %define %%sizeUsed 0
    %ifnum %1
        %define %%size %1
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
           %define bReg reg(%%size,%%group)
           %exitrep
        %endif
        %assign %%group %%group+1
    %endrep
    
    push bReg
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
    %else
        %assign %%stop %3
    %endif

    %assign %%start %2+1

    %substr %%str %%str %%start,%%stop
    %deftok %%str %%str
    retm %%str
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