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

; toStr(token)
%macro toStr 1
    %ifstr %1
        retm %1
    %else
        %defstr %%str %1
        retm %%str
    %endif
%endmacro

; returns values from a macro to __1 ... __N
; s: -> use stackcontext
; retm(outs)
%macro retm 1-*

    
    %ifidn %1,s:
        %xdefine %%extend %$__
        %assign %%stackUsed 1
    %else
        %xdefine %%extend __
        %assign %%stackUsed 0
    %endif

    
    %xdefine %[%%extend]0 %eval(%0-%%stackUsed)
    %assign %%i 1
    %rotate %%stackUsed
    %rep %eval(%0-%%stackUsed)
        %xdefine %%index %%i
        %xdefine %[%%extend]%[%%i] %1
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

    %strlen %%lenStr1 %%str1
    %strlen %%lenStr2 %%str2
    %define %%sub ''
    %assign %%i 1
    %assign %%loopTimes (%%lenStr1-%%lenStr2)+1
    retm -1
    %if %%loopTimes<=0
        %exitmacro
    %endif

    %rep %%loopTimes
        %substr %%sub %%str1 %%i,%%lenStr2
        %ifidni %%sub,%%str2
            retm %eval(%%i-1)
            %exitrep
        %endif
        %assign %%i %%i+1
    %endrep
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
    %strlen %%len %%str
    %if %%len>0
        %deftok %%str %%str
        retm %%str
    %else
        retm emptyToken
    %endif
%endmacro

%define emptyToken @@EMPTY@@
%define isEmpty(token) %isidn(token,emptyToken)

; checks if a token is a float number
%macro isTokenFloat 1
    findInToken %1 , .
    %if __1=-1
        retm 0
        %exitmacro
    %endif
    %xdefine %%dotIndex __1

    ; checks if x is a number in x.y
    subToken %1,0,%%dotIndex
    %ifnum __1
    %else
        retm 0
        %exitmacro
    %endif

    ; checks if y is a number in x.y
    subToken %1,%%dotIndex+1
    %ifnum __1
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
        %if __1
            retm 1,1
        %else
            retm 0,0
        %endif
    %endif    
%endmacro

%macro tokenLen 1
    toStr %1
    %strlen %%len __1
    retm %%len
%endmacro

; isInputFloat(token...)
; checks if at least one token is a float const or float ref
%macro isInputFloat 1-*
    retm 0
    %rep %0
        isTokenFloat %1
        %if __1 == 1
            retm 1
            %exitrep
        %elifidn float(%1),1
            retm 1
            %exitrep
        %endif
        %rotate 1
    %endrep
%endmacro



; converts a token to a number and return the type(0=int,1=float)
;TokenToNum(token)
%macro TokenToNum 1
    isTokenNum %1
    %if __1 == 1 && __2 == 1
        retm %eval(__float64__(%1)),__2
    %else
        retm %1,__2
    %endif
%endmacro

; check if a number is in a current byte size
; isNumInSize(num,size)
%define isNumInSize(num,size) %eval(-((2<<(size*8-2))-1) <= num && num <= (2<<(size*8-2))-1 ? 1 : 0)

; clearSpaces(token)->token without spaces
%macro clearSpaces 1
    replaceToken %1, " ", ""
%endmacro

;replaceToken(original,old,new,times?)
%macro replaceToken 3-4
    %if %0==4
        %xdefine %%replaceTimes %4
    %else
        %define %%replaceTimes 10000
    %endif

    tokenLen %2
    %assign %%size __1

    %xdefine %%newToken %1
    %rep %%replaceTimes
    findInToken %%newToken,%2
    %if __1 == -1
        %exitrep
    %endif   

    %assign %%index __1
    subToken %%newToken,0,%%index
    %xdefine %%leftPart __1
    

    subToken %%newToken,%eval(%%index+%%size),-1
    %xdefine %%rightPart __1



    
    %if isEmpty(%%rightPart)
        %if isEmpty(%%leftPart)
            %xdefine %%newToken %3
        %else
            %xdefine %%newToken %%leftPart%+%3
        %endif
    %elif isEmpty(%%leftPart)
        %xdefine %%newToken %3%+%%rightPart
    %else
        %xdefine %%newToken %%leftPart%+%3%+%%rightPart
    %endif
    %endrep
    retm %%newToken
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

    %define %%sub '' 
    %assign %%i %%startIndex+2

    %assign %%loopTimes (%%mainLen-%%pareLen-%%startIndex)+1
    %if %%loopTimes<=0
        %exitmacro
    %endif

    %rep %%loopTimes
        %substr %%sub %%mainStr %%i,%%pareLen

        %ifidni %%sub,%%endStr
            %assign %%count %%count-1
        %elifidni %%sub,%%startStr
            %assign %%count %%count+1
        %endif
        
        %if %%count==0
            retm %%startIndex,%eval(%%i-1)
            %exitrep
        %endif

        %assign %%i %%i+1
    %endrep
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

    %ifidn %1,@
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

    %ifidn %1,|
        retm 1
        %exitmacro
    %endif

    %ifidn %1,&
        retm 1
        %exitmacro
    %endif

    %ifidn %1,=
        retm 1
        %exitmacro
    %endif

    %ifidn %1,!
        retm 1
        %exitmacro
    %endif

    %ifidn %1,<
        retm 1
        %exitmacro
    %endif

    %ifidn %1,>
        retm 1
        %exitmacro
    %endif

    %ifidn %1,:
        retm 1
        %exitmacro
    %endif

    retm 0
%endmacro 

; getOperand(token,operatorIndex,operatorSize)-> lhs,rhs,expression
%macro getOperand 3
    %assign %%size %3

    tokenLen %1
    %assign %%max __1

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

    subToken %1,%2,%%stop
    %xdefine %%expression __1

    subToken %1,%eval(%%size + %2),%%stop
    %xdefine %%rhs __1
    retm %%rhs,%%expression
%endmacro

; get2operands(token,operatorIndex,operatorSize)-> lhs,rhs,expression
%macro get2operands 3
    %assign %%size %3 ; 2


    tokenLen %1 
    %assign %%max __1 ; 4
    %assign %%min 0

    %assign %%i %2-1
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

; evalOperator2Operands(mainToken,operator,operatorMacro)
%macro evalOperator2Operands 3
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
        %xdefine %%currentExpression __3

        %xdefine %%varName _TEV_ %+ varCount
        

        newt %%varName,8


        %3 %%operator1,%%operator2,%%varName
        replaceToken %%expression,%%currentExpression,%%varName
        %xdefine %%expression __1
        %assign varCount varCount+1
    %endrep
    retm %%expression
%endmacro

; evalOperator1Operand(mainToken,operator,operatorMacro)
%macro evalOperator1Operand 3
    tokenLen %2
    %assign %%operatorLen __1
    %xdefine %%expression %1
    %rep 100000
        findInToken %%expression,%2
        %if __1 == -1
            %exitrep
        %endif

        getOperand %%expression,__1,%%operatorLen

        %xdefine %%operator1 __1
        %xdefine %%currentExpression __2

        %xdefine %%varName exptempvar %+ varCount
        
        newt %%varName,8


        %3 %%operator1,%%varName
        replaceToken %%expression,%%currentExpression,%%varName
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

            evalOperator1Operand %$expression,@,lea
            %xdefine %$expression __1

            evalOperator2Operands %$expression,**,pow
            %xdefine %$expression __1

            evalOperator2Operands %$expression, * ,mul
            %xdefine %$expression __1

            evalOperator2Operands %$expression, / ,div
            %xdefine %$expression __1

            evalOperator2Operands %$expression, % ,mod
            %xdefine %$expression __1
    
            evalOperator2Operands %$expression, - ,sub
            %xdefine %$expression __1

            evalOperator2Operands %$expression, + ,add
            %xdefine %$expression __1

            evalOperator2Operands %$expression, == ,eq
            %xdefine %$expression __1

            evalOperator2Operands %$expression,>,greater
            %xdefine %$expression __1

            evalOperator2Operands %$expression,<,lower
            %xdefine %$expression __1

            evalOperator2Operands %$expression,>=,greaterEq
            %xdefine %$expression __1

            evalOperator2Operands %$expression,<=,lowerEq
            %xdefine %$expression __1

            evalOperator1Operand %$expression,!,bnot
            %xdefine %$expression __1

            evalOperator2Operands %$expression,&&,bAnd
            %xdefine %$expression __1

            evalOperator2Operands %$expression,^^,bXor
            %xdefine %$expression __1

            evalOperator2Operands %$expression,||,bOr
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

%define max(x,y) %eval((x>=y)*(x)+(x<y)*(y))
%define min(x,y) %eval( (x>=y)*(y)+(x<y)*(x))