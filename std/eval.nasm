;rbp:

%macro startTempBp 0
    %if inProc
        %assign tempRbpOffset locals(procName)+heldSize(procName)
    %else
        %assign tempRbpOffset 0
        push rbp
        mov rbp,rsp
    %endif
    sub rsp,allocateTempBp
%endmacro

%macro endTempBp 0
    add rsp,allocateTempBp
    %if !inProc
        pop rbp
    %endif
%endmacro

; newtbp(name,size,times,depth)
%macro newtbp 4
    %assign tempRbpOffset tempRbpOffset+%2*%3
    retm rbp-tempRbpOffset
%endmacro

;rsp:

%macro startTempSp 0
    %assign tempSpOffset 0
%endmacro

; newtsp(name,size,times,depth)
%macro newtsp 4
    %assign tempSpOffset tempSpOffset+%2
    retm rsp-tempSpOffset
%endmacro

; mixed:

; startTemp(type)
%macro startTemp 1
    %ifidn %1,tbp
        startTempBp
    %else
        startTempSp
    %endif
%endmacro

; endTemp(type)
%macro endTemp 1
    %ifidn %1,tbp
        endTempBp
    %endif
%endmacro

; checks if a token is operator
; isOperator(token)
%macro isOperator 1
    toStr %1
    
    %ifidn __1,"+"
        retm 1
    %elifidn __1,"-"
        retm 1
    %elifidn __1,"*"
        retm 1
    %elifidn __1,"/"
        retm 1
    %elifidn __1,"|"
        retm 1
    %elifidn __1,"&"
        retm 1
    %elifidn __1,"="
        retm 1
    %elifidn __1,"!"
        retm 1
    %elifidn __1,"<"
        retm 1
    %elifidn __1,">"
        retm 1
    %elifidn __1,"~"
        retm 1
    %elifidn __1,"^"
        retm 1
    %elifidn __1,"("
        retm 1
    %elifidn __1,')'
        retm 1
    %elifidn __1,'@'
        retm 1
    %else
        retm 0
    %endif
%endmacro

%macro isSymbol 1
    toStr %1
    %xdefine %%token __1
    isOperator %%token
    %if __1
        retm 1
    %elifidn %%token,":"
        retm 1
    %else
        retm 0
    %endif
%endmacro

; checks if a token has operator
%macro hasOperator 1
    %xdefine %%str %str(%1)


    %strlen %%len %%str
    %assign %%i 1
    %assign %%stringMode 0
    %assign %%stringType 0
    %assign %%stringLen 0

    %rep %%len
        %substr %%sub %%str %%i,1
        isStringOpen %%sub
        %if __1
            %if %%stringMode
                %assign %%stringMode (%%stringType!=__2)
                %assign %%stringLen (%%stringType!=__2)*(%%stringLen)
            %else
                %assign %%stringMode 1
                %assign %%stringType __2
                %assign %%stringLen 0
            %endif
        %endif
        %if %%stringMode
            %assign %%stringLen %%stringLen+1
            %if %%stringLen>4
                retm 1
                %exitrep
            %endif
        %else
            isOperator %%sub
            %if __1
                retm 1
                %exitrep
            %endif
        %endif
        %assign %%i %%i+1
        retm 0
    %endrep
%endmacro


; findOperator1Operand(expression,operator) -> index,streak
%macro findOperator1Operand 2
    toStr %1
    %xdefine %%str1 __1
    toStr %2
    %xdefine %%str2 __1

    %assign %%stringMode 0
    %assign %%stringType 0

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
            %ifidni %%sub,%%str2
                ; checks if after the operator theres an operand and not operator
                %substr %%after %%str1 %%i+%%lenStr2,1
                isSymbol %%after
                %if !__1
                    ; if operator at start its 1-Operand Operator
                    %if %%i==1
                        retm %eval(%%i-1),%%streak
                        %exitrep
                    %else
                       ; check if before the operator theres another one, 1-2 -> "-" is 2 operands,1&!1 -> "!" is 1 operand
                        %substr %%before %%str1 %%i-1,1
                        isSymbol %%before
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
        %substr %%sub %%str1 %%i,%%lenStr2
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
            %ifidni %%sub,%%str2
                %if %%i!=1
                    %substr %%before %%str1 %%i-1,1
                    isOperator %%before
                    %if !__1
                        %substr %%after %%str1 %%i+%%lenStr2,1
                        isOperator %%after
                        %if !__1
                            retm %eval(%%i-1)
                            %exitrep
                        %endif
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
    %define %%expression %str(%1)
    %rep 100000
        
        
        findInToken %%expression,(
        %if __1 == -1
            %exitrep
        %endif

        %assign %%index __1
        subString %%expression,%eval(%%index-1),%%index
        %xdefine %%before __1
        isOperator __1
        %if !(__1||isEmpty(%%before))
            getLOperand %tok(%%expression),%%index,1
            %assign %%count %%count+outs(__1)/8
        %endif

        subString %%expression,%eval(%%index+1)
        %xdefine %%expression __1
    %endrep    
    retm %%count
%endmacro

; containsProcCall(expression)
%macro containsProcCall 1
    %define %%expression %1
    %rep 100000
        findInToken %%expression,(
        %if __1 == -1
            retm 0
            %exitrep
        %endif

        %assign %%index __1
        subToken %%expression,%eval(%%index-1),%%index
        %xdefine %%before __1
        isOperator __1
        %if !(__1||isEmpty(%%before))
            retm 1
            %exitrep
        %endif

        subToken %%expression,%eval(%%index+1)
        %xdefine %%expression __1
    %endrep    
%endmacro

; getROperand(token,operatorIndex,operatorSize)-> rightOperand,expression,stop
%macro getROperand 3
    %assign %%size %3

    tokenLen %1
    %assign %%max __1

    %assign %%stringMode 0
    %assign %%stringType 0

    %assign %%i %2+%%size+1
    %rep 100000
        subString %str(%1),%eval(%%i-1),%%i
        %xdefine %%rightOperand __1
                
        isStringOpen %%rightOperand
        %if __1
            %if %%stringMode
                %assign %%stringMode (%%stringType!=__2)
            %else
                %assign %%stringMode 1
                %assign %%stringType __2
            %endif
        %endif
        %if !%%stringMode
            isSymbol %%rightOperand
            %if __1
                %assign %%stop %%i-1
                %exitrep
            %elif %%i==%%max
                %assign %%stop %%i
                %exitrep
            %endif
        %endif

        %assign %%i %%i+1
    %endrep

    subToken %1,%2,%%stop
    %xdefine %%expression __1

    subToken %1,%eval(%%size + %2),%%stop
    %xdefine %%rightOperand __1
    retm %%rightOperand,%%expression,%%stop 
%endmacro

; getLOperand(token,operatorIndex,operatorSize)-> leftOperand,expression,start
%macro getLOperand 3

    %assign %%stringMode 0
    %assign %%stringType 0
    %assign %%min 0
    %assign %%i %2-1
    %rep 100000
        subString %str(%1),%%i,%eval(%%i+1)
        %xdefine %%leftOperand __1
        isStringOpen %%leftOperand
        %if __1
            %if %%stringMode
                %assign %%stringMode (%%stringType!=__2)
            %else
                %assign %%stringMode 1
                %assign %%stringType __2
            %endif
        %endif
        %if !%%stringMode
            isSymbol %%leftOperand
            %if __1
                %assign %%start %%i+1
                %exitrep
            %elif %%i<%%min
                %assign %%start 0
                %exitrep
            %endif
        %endif
        %assign %%i %%i-1
    %endrep

    subToken %1,%%start,%eval(%2+%3)
    %xdefine %%expression __1
    

    subToken %1,%%start,%2
    %xdefine %%leftOperand __1

    retm %%leftOperand,%%expression,%%start
%endmacro

; returns the amount of operators and proc calls outs
%macro countOperators 1
    toStr %1
    %xdefine %%str __1
    %assign %%count 0
    %strlen %%len %%str

    %assign %%stringMode 0
    %assign %%stringType 0
    %assign %%stringLen 0

    %assign %%i 1

    %rep %%len
        %substr %%sub %%str %%i,1
        isStringOpen %%sub
        %if __1
            %if %%stringMode
                %assign %%stringMode (%%stringType!=__2)
                %assign %%stringLen (%%stringType!=__2)*(%%stringLen)
            %else
                %assign %%stringMode 1
                %assign %%stringType __2
            %endif
        %endif
        %if %%stringMode
            %assign %%stringLen %%stringLen+1
            %if %%stringLen==5
                %assign %%count %%count+2
            %endif
        %else
            isOperator %%sub
            %if __1
                %assign %%count %%count+1
            %endif
        %endif
        %assign %%i %%i+1
    %endrep

    countProcCallsOuts %1
    retm %eval(%%count+__1)
%endmacro

; get2operands(token,operatorIndex,operatorSize)-> leftOperand,rightOperand,expression
%macro get2operands 3
    
    getLOperand %1,%2,%3
    %xdefine %%leftOperand __1
    %xdefine %%start __3

    getROperand %1,%2,%3
    %xdefine %%rightOperand __1
    %xdefine %%stop __3

    subToken %1,%%start,%%stop
    %xdefine %%expression __1

    retm %%leftOperand,%%rightOperand,%%expression
%endmacro

; evalOperator2Operands(mainToken,operator,operatorMacro,useEvalForConst)
%macro evalOperator2Operands 4
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
        %if %4 && %isnum(%%operand1) && %isnum(%%operand2)
            %assign %%value %eval(%%currentExpression)
            replaceToken %%expression,%%currentExpression,%%value
        %else

            %xdefine %%varName _TEV %+ varCount
        
            new tempType qword %%varName

            %3 %%operand1,%%operand2,%%varName
            replaceToken %%expression,%%currentExpression,%%varName
        %endif
        %xdefine %%expression __1
        %assign varCount varCount+1
    %endrep
    retm %%expression
%endmacro

; evalOperator1Operand(mainToken,operator,operatorMacro,streakUsed,useEvalForConst)
%macro evalOperator1Operand 5
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
        %if %5 && %isnum(%%operand)
            %assign %%value %eval(%%currentExpression)
            replaceToken %%expression,%%currentExpression,%%value
        %else
            %xdefine %%varName _TEV0 %+ varCount
        
            new tempType qword %%varName

            %if %4
                %3 %%operand,%%varName,%%streak
            %else
                %3 %%operand,%%varName
            %endif

            replaceToken %%expression,%%currentExpression,%%varName
        %endif
        %xdefine %%expression __1
        %assign varCount varCount+1
    %endrep
    retm %%expression
%endmacro

; x-3*(x-4),(,),1
; expression,openChar,closeChar -> oldExpression,evaledExpression
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
        
        %if !isEmpty(%%expression)
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
            %endif
        %endif

        subToken %%token,%eval(%%endIndex+1)
        %xdefine %%token __1
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

        %assign %%outs outs(%%procName)/8

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
            %xdefine %%newExpression [_TEV %+ %%startVarCount
            %assign %%i %%startVarCount+1
            %rep %%outs-1
                %xdefine %%newExpression %%newExpression %+ : %+ %[_TEV %+ %%i]
                %assign %%i %%i+1
            %endrep            
            %xdefine %%newExpression %%newExpression%+]
        %endif
        subToken %%expression,%%startIndex,%%endInputIndex
        replaceToken %%expression,__1,%%newExpression,1
        %xdefine %%expression __1
    %endrep
    retm %%expression
%endmacro

%assign stringCount 0

%macro evalString 1
    %define %%symbol '"'
    %define %%expression %str(%1)
    %rep 2
        %rep 2
            %assign %%startIndex -1
            %assign %%stopIndex -1
            %assign %%found 0
            %assign %%stringMode 0
            %assign %%stringType 0
            %xdefine %%strExpression %%expression
            %strlen %%len %%strExpression
            %assign %%i 1
            %rep %%len
                %substr %%sub %%strExpression %%i,1
                isStringOpen %%sub
                %if __1
                    %if %%stringMode
                        %if (%%stringType==__2)
                            %if %%i-%%startIndex>4
                                %assign %%startIndex %%startIndex-1
                                %assign %%stopIndex %%i
                                %assign %%found 1
                                %exitrep
                            %endif
                        %endif
                    %else
                        %assign %%startIndex %%i
                        %assign %%stringMode 1
                        %assign %%stringType __2
                    %endif

                %endif
                %assign %%i %%i+1
            %endrep

            %if !%%found
                %exitrep
            %endif

            subString %%strExpression,%%startIndex,%%stopIndex
            %xdefine %%string __1
            %xdefine %%varName S %+ stringCount %+ S
            %assign stringCount stringCount+1
            new const byte %%varName[] = %tok(%%string)
            replaceToken %tok(%%expression),%%string,@%[%%varName]
            %xdefine %%expression %str(__1)
        %endrep
        %define %%symbol "'"
    %endrep
    retm %tok(%%expression)
%endmacro

%macro eval 1-2
    %define tempType tsp
    %define %%expression %1
    isString %%expression
    %if __1
        retm %%expression
        %exitmacro
    %endif
    clearSpaces %%expression
    %xdefine %%expression __1
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
            ; searchGroup %$expression,[,]
            %ifnidn __1,-1
                %push
                %xdefine %$original __1
                %xdefine %$expression __2
                %assign %%recursiveCount %%recursiveCount+1
            %else
                evalString %$expression
                %xdefine %$expression __1

                evalProc %$expression
                %xdefine %$expression __1

                evalOperator1Operand %$expression,@,lea,1,0
                %xdefine %$expression __1

                evalOperator1Operand %$expression,~,not,0,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression,**,pow,0
                %xdefine %$expression __1

                evalOperator2Operands %$expression,*,mul,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression, / ,div,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression, % ,mod,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression, - ,sub,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression, + ,add,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression,<<,sal,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression,>>,sar,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression, != ,nEq,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression, == ,eq,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression,>=,greaterEq,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression,<=,lowerEq,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression,>,greater,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression,<,lower,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression, & ,and,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression, ^ ,xor,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression, | ,or,1
                %xdefine %$expression __1

                evalOperator1Operand %$expression,!,bnot,0,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression,&&,bAnd,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression,^^,bXor,1
                %xdefine %$expression __1

                evalOperator2Operands %$expression,||,bOr,1
                %xdefine %$expression __1


                %assign %%recursiveCount %%recursiveCount-1
                %if %%recursiveCount == 0
                    %xdefine %%expression %$expression    
                    %exitrep
                %endif

                %xdefine __1 %str(%$original)
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