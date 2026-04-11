;defines a reg that isnt used as r
;eg: resr(s:4,rax,rbx)->ecx
;resr(?size-1,used-regs-1-*)
%macro resr 0-*
    %assign %%group 0
    %define %%foundReg 0
    %define %%sizeUsed 0
    
    findInToken %1,s:
    %if __1 != -1
        subToken %1,__1+2,-1
        %define %%size __1
        %define %%sizeUsed 1
    %else
        %define %%size 8
    %endif

    %rep group(r15)+1
        %rotate %%sizeUsed
        %define %%foundReg 1
        %rep %0-%%sizeUsed
            %if isReg(%1)
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

%macro isStringOpen 1
    toStr %1
    %xdefine %%token __1
    %ifidn %%token,"'"
        retm 1,0
    %elifidn %%token,'"'
        retm 1,1
    %else
        retm 0,0
    %endif
%endmacro

%macro isString 1
    %defstr %%str %1
    %substr %%sub %%str 1
    %if !(%isidn(%%sub,"'") || %isidn(%%sub,'"'))
        retm 0
        %exitmacro
    %endif
    
    %substr %%sub %%str %strlen(%%str)
    %if !(%isidn(%%sub,"'") || %isidn(%%sub,'"'))
        retm 0
        %exitmacro
    %endif
    retm 1
%endmacro

; toStr(token)
%macro toStr 1
    isString %1
    %if __1
        retm %1
    %else
        %defstr %%str %1
        retm %%str
    %endif
%endmacro

; isPtr(token)
%macro isPtr 1
    tokenCount %1,@
    retm __1>0,__1
%endmacro
; returns values from a macro to __1 ... __N
; __0 = count
; retm(outs)
%macro retm 1-*
    %xdefine __0 %0
    %assign %%i 1
    %rep %0
        %xdefine __%[%%i] %1
        %rotate 1
        %assign %%i %%i+1
    %endrep
%endmacro

; returns values from a macro to %$__1 ... %$__N
; %$__0 = count 
; retm(outs)
%macro retms 1-*
    %xdefine %$__0 %0
    %assign %%i 1
    %rep %0
        %xdefine %$__%[%%i] %1
        %rotate 1
        %assign %%i %%i+1
    %endrep
%endmacro


; findInToken(token1,token2)->index
%macro findInToken 2
    toStr %1
    %xdefine %%str1 __1
    toStr %2
    %xdefine %%str2 __1

    %assign %%stringMode 0
    %assign %%stringType 0

    %strlen %%lenStr1 %%str1
    %strlen %%lenStr2 %%str2
    %assign %%i 1
    %assign %%loopTimes (%%lenStr1-%%lenStr2)+1
    
    %if %%loopTimes<=0
        retm -1
        %exitmacro
    %endif

    %rep %%loopTimes
        %if !%%stringMode
            %substr %%sub %%str1 %%i,%%lenStr2
            %ifidni %%sub,%%str2
                retm %eval(%%i-1)
                %exitrep
            %endif
        %endif
        %substr %%sub %%str1 %%i,1
        isStringOpen %%sub
        %if __1
            %if %%stringMode
                %assign %%stringMode (%%stringType!=__2)
            %else
                %assign %%stringMode 1
                %assign %%stringType __2
            %endif
        %endif
        %assign %%i %%i+1
        retm -1
    %endrep
%endmacro

%macro subString 2-3
    toStr %1
    %xdefine %%str __1
    %if %0=2
        %assign %%stop -1
    %elif %3>0
        %assign %%stop %3-%2
    %else
        %assign %%stop %3
    %endif

    %assign %%start %2+1

    %substr %%str %%str %%start,%%stop
    retm %%str
%endmacro

; tokenCount(token1,token2)->count
%macro tokenCount 2
    toStr %1
    %xdefine %%str1 __1
    toStr %2
    %xdefine %%str2 __1

    %strlen %%lenStr1 %%str1
    %strlen %%lenStr2 %%str2
    %define %%sub ''
    %assign %%i 1
    %assign %%count 0
    %assign %%loopTimes (%%lenStr1-%%lenStr2)+1
    %if %%loopTimes<=0
        retm 0
        %exitmacro
    %endif

    %rep %%loopTimes
        %substr %%sub %%str1 %%i,%%lenStr2
        %ifidni %%sub,%%str2
            %assign %%count %%count+1
        %endif
        %assign %%i %%i+1
    %endrep
    retm %%count
%endmacro
; subToken(token,start,stop?)->subtoken
%macro subToken 2-3
    subString %{1:-1}
    %xdefine %%str __1
    %strlen %%len %%str
    %if %%len>0
        %deftok %%str %%str
        retm %%str
    %else
        retm emptyToken
    %endif
%endmacro

%define emptyToken @@EMPTY@@
%define isEmpty(token) (%isidn(token,emptyToken)||%isidn(token,"")||%isidn(token,"@@EMPTY@@"))
%define isTokenFloat(x) %eval(!%isnum(0%+x)&&!%isid(x))
%define isTokenNum(x) %eval(%isnum(x)||isTokenFloat(x)||%isstr(x))
%define numType(x) isTokenFloat(x)

%macro tokenLen 1
    toStr %1
    %strlen %%len __1
    retm %%len
%endmacro

%macro isInputFloat 1-*
    %rep %0
        %if isTokenFloat(%1)
            retm 1
            %exitrep
        %endif

        %if isRef(%1)
            splitIndex %1
            %if float(__1)
                retm 1
                %exitrep
            %endif
        %endif
        retm 0
    %rotate 1
    %endrep
%endmacro

; converts a token to a number and return the type(0=int,1=float)
;TokenToNum(token)
%macro TokenToNum 1
    %if isTokenFloat(%1)
        retm %eval(__float64__(%1)),1
    %elifnum %1
        retm %1,0
    %else
        retm %1,0
    %endif
%endmacro

; check if a number is in a current byte size
; isNumInSize(num,size)
%define isNumInSize(num,size) %eval(-((2<<(size*8-2))-1) <= num && num <= (2<<(size*8-2))-1 ? 1 : 0)

; clearSpaces(token)->token without spaces
%macro clearSpaces 1
    toStr %1
    %xdefine %%str __1

    %xdefine %%new ""

    %strlen %%len %%str
    %define %%sub ''
    %assign %%i 1
    %assign %%count 0

    %assign %%stringMode 0
    %assign %%stringType 0

    %rep %%len
        %substr %%sub %%str %%i,1
        isStringOpen %%sub
        %if __1
            %if %%stringMode
                %assign %%stringMode (%%stringType!=__2)
            %else
                %assign %%stringMode 1
                %assign %%stringType __2
            %endif
        %endif
        %if !%isidni(%%sub," ")||%%stringMode
            %xdefine %%new %strcat(%%new,%%sub)
        %endif
        %assign %%i %%i+1
    %endrep
    retm %tok(%%new)
%endmacro

;replaceToken(original,old,new,times?)
%macro replaceToken 3-4
    %if %0==4
        %xdefine %%replaceTimes %4
    %else
        %define %%replaceTimes 100000
    %endif

    tokenLen %2
    %assign %%size __1
    toStr %3
    %xdefine %%new __1

    %xdefine %%newString %str(%1)
    %rep %%replaceTimes
        findInToken %%newString,%2
        %if __1 == -1
            %exitrep
        %endif

        %assign %%index __1
        subString %%newString,0,%%index
        %xdefine %%leftPart __1
    

        subString %%newString,%eval(%%index+%%size),-1
        %xdefine %%rightPart __1

        %xdefine %%newString %strcat(%%leftPart,%%new,%%rightPart)

    %endrep
    %if %strlen(%%newString)==0
        retm emptyToken
    %else
        retm %tok(%%newString)
    %endif
%endmacro

%macro sumSize 1-*
    %assign %%size 0
    %rep %0
        %assign %%size %%size+size(%1)
        %rotate 1
    %endrep
    retm %%size
%endmacro

; findPare(mainToken,start,stop)
%macro findPare 3
    findInToken %1,%2

    %assign %%stringMode 0
    %assign %%stringType 0

    %xdefine %%startIndex __1

    retm -1,-1

    %if %%startIndex == -1
        %exitmacro
    %endif

    %assign %%count 1

    %xdefine %%endIndex -1

    toStr %1
    %xdefine %%mainStr __1
    toStr %2
    %xdefine %%startStr __1
    toStr %3
    %xdefine %%endStr __1
    
    %strlen %%mainLen %%mainStr
    %strlen %%pareLen %%startStr
    %assign %%i %%startIndex+2

    %assign %%loopTimes (%%mainLen-%%pareLen-%%startIndex)+1
    %if %%loopTimes<=0
        retm -1,-1
        %exitmacro
    %endif

    %rep %%loopTimes
        %substr %%sub %%mainStr %%i,%%pareLen
        isStringOpen %%sub
        %if __1
            %if %%stringMode
                %assign %%stringMode (%%stringType!=__2)
            %else
                %assign %%stringMode 1
                %assign %%stringType __2
            %endif
        %endif
        %if !%%stringMode
            %ifidni %%sub,%%endStr
                %assign %%count %%count-1
            %elifidni %%sub,%%startStr
                %assign %%count %%count+1
            %endif
        
            %if %%count==0
                retm %%startIndex,%eval(%%i-1)
                %exitrep
            %endif
        %endif
        %assign %%i %%i+1
    %endrep
%endmacro

%define max(x,y) %eval((x>=y)*(x)+(x<y)*(y))
%define min(x,y) %eval( (x>=y)*(y)+(x<y)*(x))