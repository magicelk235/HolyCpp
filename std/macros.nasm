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

; isPtr(token)
%macro isPtr 1
    tokenCount %1,@
    retm __1>0,__1
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
    replaceToken %1, " ", ""
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

    toStr %%leftPart
    %xdefine %%leftStr __1
    toStr %%rightPart
    %xdefine %%rightStr __1

    %if isEmpty(%%rightStr)
        %if isEmpty(%%leftStr)
            %if isEmpty(%3)
                %xdefine %%newToken emptyToken
            %else
                %xdefine %%newToken %3
            %endif
        %elif isEmpty(%3)
            %xdefine %%newToken %%leftPart
        %else
            %xdefine %%newToken %%leftPart%+%3
        %endif
    %elif isEmpty(%%leftStr)
        %if isEmpty(%3)
            %xdefine %%newToken %%rightPart
        %else
            %xdefine %%newToken %3%+%%rightPart
        %endif
    %elif isEmpty(%3)
        %xdefine %%newToken %%leftPart%+%%rightPart
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
        retm -1
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

    %ifidn %1,~
        retm 1
        %exitmacro
    %endif

    %ifidn %1,^
        retm 1
        %exitmacro
    %endif

    %ifidn %1,(
        retm 1
        %exitmacro
    %endif

    %ifidn %1,)
        retm 1
        %exitmacro
    %endif

    retm 0
%endmacro

; checks if a token is separator
; isSeparator(token)
%macro isSeparator 1
    %ifidn %1,:
        retm 1
        %exitmacro
    %endif

    %ifidn %1,(
        retm 1
        %exitmacro
    %endif

    %ifidn %1,)
        retm 1
        %exitmacro
    %endif

    retm 0
%endmacro

%macro isSymbol 1
    isOperator %1
    %if __1
        retm 1
    %else
        isSeparator %1
        retm __1
    %endif
%endmacro

; findOperator1Operand(expression,operator) -> index,streak
%macro findOperator1Operand 2
    toStr %1
    %xdefine %%str1 __1
    toStr %2
    %xdefine %%str2 __1

    ; !!!name -> 2, !name -> 0
    %assign %%streak 0

    %strlen %%lenStr1 %%str1
    %strlen %%lenStr2 %%str2
    %assign %%i 1
    %assign %%loopTimes (%%lenStr1-%%lenStr2)+1
    %if %%loopTimes<=0
        retm -1
        %exitmacro
    %endif
    %rep %%loopTimes
        %substr %%sub %%str1 %%i,%%lenStr2
        %ifidni %%sub,%%str2
            ; checks if after the operator theres an operand and not operator
            %substr %%after %%str1 %%i+%%lenStr2,1
            %deftok %%after %%after
            isOperator %%after
            %if !__1
                ; if operator at start its 1-Operand Operator
                %if %%i==1
                    retm %eval(%%i-1),%%streak
                    %exitrep
                %else
                   ; check if before the operator theres another one, 1-2 -> "-" is 2 operands,1&!1 -> "!" is 1 operand
                    %substr %%before %%str1 %%i-1,1
                    %deftok %%before %%before
                    isOperator %%before
                    %if __1
                        retm %eval(%%i-1),%%streak
                        %exitrep
                    %endif
                %endif
            %endif
            %assign %%streak %%streak+1
        %else
            %assign %%streak 0
        %endif
        %assign %%i %%i+1
        retm -1
    %endrep
%endmacro

%macro findOperator2Operands 2
    toStr %1
    %xdefine %%str1 __1
    toStr %2
    %xdefine %%str2 __1

    %strlen %%lenStr1 %%str1
    %strlen %%lenStr2 %%str2
    %assign %%i 1
    %assign %%loopTimes (%%lenStr1-%%lenStr2)+1
    %if %%loopTimes<=0
        retm -1
        %exitmacro
    %endif

    %rep %%loopTimes
        %substr %%sub %%str1 %%i,%%lenStr2
        %ifidni %%sub,%%str2
            %if %%i!=1
                %substr %%before %%str1 %%i-1,1
                %deftok %%before %%before
                isOperator %%before
                %if !__1
                    %substr %%after %%str1 %%i+%%lenStr2,1
                    %deftok %%after %%after
                    isOperator %%after
                    %if !__1
                        retm %eval(%%i-1)
                        %exitrep
                    %endif
                %endif
            %endif
        %endif
        %assign %%i %%i+1
        retm -1
    %endrep
%endmacro

%macro countProcCallsOuts 1
    %assign %%count 0
    %define %%expression %1
    %rep 100000
        findInToken %%expression,(
        %if __1 == -1
            %exitrep
        %endif

        %assign %%index __1
        subToken %%expression,%eval(%%index-1),%%index
        %xdefine %%before __1
        isOperator __1
        %if !(__1||isEmpty(%%before))
            getLOperand %%expression,%%index,1
            %assign %%count %%count+outs(__1)
        %endif

        subToken %%expression,%eval(%%index+1)
        %xdefine %%expression __1
    %endrep    
    retm %%count
%endmacro

%macro countProcCalls 1
    %assign %%count 0
    %define %%expression %1
    %rep 100000
        findInToken %%expression,(
        %if __1 == -1
            %exitrep
        %endif

        %assign %%index __1
        subToken %%expression,%eval(%%index-1),%%index
        %xdefine %%before __1
        isOperator __1
        %if !(__1||isEmpty(%%before))
            %assign %%count %%count+1
        %endif

        subToken %%expression,%eval(%%index+1)
        %xdefine %%expression __1
    %endrep    
    retm %%count
%endmacro

; containsProcCall(expression)
%macro containsProcCall 1
    countProcCalls %1
    retm %eval(__1!=0)
%endmacro

; getOperand(token,operatorIndex,operatorSize)-> rhs,expression,stop
%macro getROperand 3
    %assign %%size %3

    tokenLen %1
    %assign %%max __1

    %assign %%i %2+%%size+1
    %rep 100000
        subToken %1,%eval(%%i-1),%%i
        %xdefine %%rhs __1
        isSymbol %%rhs
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
    retm %%rhs,%%expression,%%stop 
%endmacro

; getOperand(token,operatorIndex,operatorSize)-> lhs,expression,start
%macro getLOperand 3

    %assign %%min 0
    %assign %%i %2-1
    %rep 100000
        subToken %1,%%i,%eval(%%i+1)
        %xdefine %%lhs __1
        isSymbol %%lhs
        %if __1
            %assign %%start %%i+1
            %exitrep
        %elif %%i==%%min
            %assign %%start %%i
            %exitrep
        %endif
        %assign %%i %%i-1
    %endrep

    subToken %1,%%start,%eval(%2+%3)
    %xdefine %%expression __1
    

    subToken %1,%%start,%2
    %xdefine %%lhs __1

    retm %%lhs,%%expression,%%start
%endmacro

; returns the amount of operators and proc calls outs
%macro countOperators 1
    toStr %1
    %xdefine %%str __1
    %assign %%count 0
    %strlen %%len %%str

    %assign %%i 1

    %rep %%len
        %substr %%sub %%str %%i,1
        %deftok %%sub %%sub
        isOperator %%sub
        %if __1
            %assign %%count %%count+1
        %endif
        %assign %%i %%i+1
    %endrep

    countProcCallsOuts %1
    retm %eval(%%count+__1)
%endmacro

; checks if a token has operator
%macro hasOperator 1
    toStr %1
    %xdefine %%str __1

    %strlen %%lenStr %%str
    %assign %%i 1

    %rep %%lenStr
        %substr %%sub %%str %%i,1
        %deftok %%sub %%sub
        isOperator %%sub
        %if __1
            retm 1
            %exitrep
        %endif
        %assign %%i %%i+1
        retm 0
    %endrep
%endmacro

; get2operands(token,operatorIndex,operatorSize)-> lhs,rhs,expression
%macro get2operands 3
    
    getLOperand %1,%2,%3
    %xdefine %%lhs __1
    %xdefine %%start __3

    getROperand %1,%2,%3
    %xdefine %%rhs __1
    %xdefine %%stop __3

    subToken %1,%%start,%%stop
    %xdefine %%expression __1

    retm %%lhs,%%rhs,%%expression
%endmacro

; evalOperator2Operands(mainToken,operator,operatorMacro)
%macro evalOperator2Operands 3
    tokenLen %2
    %assign %%operatorLen __1

    %xdefine %%expression %1

    %rep 100000
        findOperator2Operands %%expression,%2
        %if __1 == -1
            %exitrep
        %endif

        get2operands %%expression,__1,%%operatorLen

        %xdefine %%operand1 __1
        %xdefine %%operand2 __2
        %xdefine %%currentExpression __3

        %xdefine %%varName _TEV %+ varCount
        
        new tempType qword %%varName

        %3 %%operand1,%%operand2,%%varName
        replaceToken %%expression,%%currentExpression,%%varName
        %xdefine %%expression __1
        %assign varCount varCount+1
    %endrep
    retm %%expression
%endmacro

; evalOperator1Operand(mainToken,operator,operatorMacro,streakUsed)
%macro evalOperator1Operand 4
    tokenLen %2
    %assign %%operatorLen __1
    %xdefine %%expression %1
    %rep 100000
        ; searches for 1-operand operator
        findOperator1Operand %%expression,%2
        %if __1 == -1
            %exitrep
        %endif

        %assign %%operatorIndex __1
        %assign %%streak __2
        

        ; gets the operand by the operator index
        getROperand %%expression,%%operatorIndex,%%operatorLen

        %xdefine %%operand __1
        %xdefine %%currentExpression __2
        %if %4
            %assign %%operatorIndex %%operatorIndex-%%streak
            subToken %%expression,%%operatorIndex,__3
            %xdefine %%currentExpression __1
        %endif

        %xdefine %%varName exptempvar %+ varCount
        
        new tempType qword %%varName

        %if %4
            %3 %%operand,%%varName,%%streak
        %else
            %3 %%operand,%%varName
        %endif

        replaceToken %%expression,%%currentExpression,%%varName
        %xdefine %%expression __1
        %assign varCount varCount+1
    %endrep
    retm %%expression
%endmacro

; x-3*(x-4),(,),1
; expression,openChar,closeChar
%macro searchGroup 3
    %define %%token %1
    %rep 100000

        %if isEmpty(%%token)
            retm -1,-1
            %exitrep
        %endif

        findPare %%token,%2,%3

        %ifidn __1,-1
            retm -1,-1
            %exitrep
        %endif

        %assign %%startIndex __1+1
        %assign %%endIndex __2

        subToken %%token,%%startIndex,%%endIndex
        %xdefine %%expression __1
        

        subToken %%token,%eval(%%startIndex-2),%eval(%%startIndex-1)
    
        %xdefine %%sub __1 
        isOperator %%sub
        %if __1||isEmpty(%%sub) ; if (...)-... or -(....) replace (,)
            subToken %1,%eval(%%startIndex-1),%eval(%%endIndex+1)
            %xdefine %%original __1
            retm %%original,%%expression
            %exitrep
        %else ; name(..) or name[....] dont replace []or()
            hasOperator %%expression

            %if __1 ; if has something to calculate
                
                retm %%expression,%%expression
                %exitrep
            %endif
            subToken %%token,%eval(%%endIndex+1)
            %xdefine %%token __1
        %endif
    %endrep
%endmacro

%macro evalProc 1
    %xdefine %%expression %1
    %assign %%outs 0
    %assign %%args 0
    %rep 100000
        findPare %%expression,(,)

        %if __1==-1
            %exitrep
        %endif

        %assign %%startInputIndex __1
        %assign %%endInputIndex __2+1
        
        subToken %%expression,%%startInputIndex,%%endInputIndex
        %xdefine %%input __1
        getLOperand %%expression,%%startInputIndex,1

        %xdefine %%procName __1
        %assign %%startIndex __3

        %assign %%outs outs(%%procName)

        %assign %%startVarCount varCount
        %rep %%outs
            %xdefine %%varName _TEV %+ varCount
            new tempType qword %%varName
            %assign varCount varCount+1
        %endrep

        %xdefine %%outArr _TEV %+ %%startVarCount
        %assign %%i %%startVarCount+1
        %rep %%outs-1
            %xdefine %%outArr %%outArr %+,%+%[_TEV %+ %%i]
            %assign %%i %%i+1
        %endrep
        
        %push 
        splitArrayToTokens %%input
        %assign %%args %$__0
        %if %%args != 0
            %xdefine %%argArr %$__1
            %assign %%i 2
            %rep %%args-1
                %xdefine %%argArr %%argArr%+,%+ %[%$ %+__ %+ %%i]
                %assign %%i %%i+1
            %endrep
        %endif
        %pop 

        %if %%args>0
            callp %%procName,%%argArr,%%outArr
        %else
            callp %%procName,%%outArr
        %endif

        %if %%outs==1
            %xdefine %%newExpression _TEV %+ %%startVarCount
        %else
            %xdefine %%newExpression [_TEV %+ %eval(varCount-1)
            %assign %%i varCount-2
            %rep %%outs-1
                %xdefine %%newExpression %%newExpression %+ : %+ %[_TEV %+ %%i]
                %assign %%i %%i-1
            %endrep            
            %xdefine %%newExpression %%newExpression%+]
        %endif
        subToken %%expression,%%startIndex,%%endInputIndex
        replaceToken %%expression,__1,%%newExpression
        %xdefine %%expression __1
    %endrep
    retm %%expression
%endmacro

%macro eval 1-2
    %define %%expression %1
    countOperators %%expression
    %if __1==0
        retm %%expression
        %exitmacro
    %endif
    %assign allocateTempBp __1*8

    clearSpaces %%expression
    %xdefine %%expression __1

    %if %0=1
        containsProcCall %%expression
        %if __1
            %define tempType tbp
        %else
            %define tempType tsp
        %endif
    %else
        %define tempType %2
    %endif

    %assign varCount 0
    %assign %%recursiveCount 1
    startTemp tempType

    %push
    %xdefine %$expression %%expression
    %xdefine %$original %%expression
    %rep 100000
        searchGroup %$expression,(,)
        %ifnidn __1,-1

            %push
            %xdefine %$original __1
            %xdefine %$expression __2

            %assign %%recursiveCount %%recursiveCount+1
        %else
            searchGroup %$expression,[,]
            %ifnidn __1,-1
                %push
                %xdefine %$original __1
                %xdefine %$expression __2
                %assign %%recursiveCount %%recursiveCount+1
            %else
                evalProc %$expression
                %xdefine %$expression __1

                evalOperator1Operand %$expression,@,lea,1
                %xdefine %$expression __1

                evalOperator1Operand %$expression,~,not,0
                %xdefine %$expression __1

                evalOperator2Operands %$expression,**,pow
                %xdefine %$expression __1

                evalOperator2Operands %$expression,.*,mulF
                %xdefine %$expression __1

                evalOperator2Operands %$expression,*,mul
                %xdefine %$expression __1

                evalOperator2Operands %$expression, / ,div
                %xdefine %$expression __1

                evalOperator2Operands %$expression, % ,mod
                %xdefine %$expression __1

                evalOperator2Operands %$expression, - ,sub
                %xdefine %$expression __1

                evalOperator2Operands %$expression, + ,add
                %xdefine %$expression __1

                evalOperator2Operands %$expression,<<,sal
                %xdefine %$expression __1

                evalOperator2Operands %$expression,>>,sar
                %xdefine %$expression __1

                evalOperator2Operands %$expression, != ,nEq
                %xdefine %$expression __1

                evalOperator2Operands %$expression, == ,eq
                %xdefine %$expression __1

                evalOperator2Operands %$expression,>=,greaterEq
                %xdefine %$expression __1

                evalOperator2Operands %$expression,<=,lowerEq
                %xdefine %$expression __1

                evalOperator2Operands %$expression,>,greater
                %xdefine %$expression __1

                evalOperator2Operands %$expression,<,lower
                %xdefine %$expression __1

                evalOperator2Operands %$expression, & ,and
                %xdefine %$expression __1

                evalOperator2Operands %$expression, ^ ,xor
                %xdefine %$expression __1

                evalOperator2Operands %$expression, | ,or
                %xdefine %$expression __1

                evalOperator1Operand %$expression,!,bnot,0
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
            %endif
        
        %endif
    %endrep
    %pop
    
    retm %%expression
%endmacro

%macro endEval 0
    endTemp tempType
%endmacro

%define max(x,y) %eval((x>=y)*(x)+(x<y)*(y))
%define min(x,y) %eval( (x>=y)*(y)+(x<y)*(x))