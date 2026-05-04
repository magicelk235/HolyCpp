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

%rmacro getPath 1
    %xdefine %%path %str(%1)
    %ifidn %substr(%%path,1,1),"<"
        %xdefine %%path %strcat("lib/",%substr(%%path,2,%strlen(%%path)-2))
    %endif

    %strlen %%pathlen %%path
    %assign %%hasDot 0
    %assign %%j 1
    %rep %%pathlen
        %substr %%sub %%path %%j,1
        %ifidni %%sub,"."
            %assign %%hasDot 1
            %exitrep
        %endif
        %assign %%j %%j+1
    %endrep

    %if !%%hasDot
        %xdefine %%path %strcat(%%path,".hcpp")
        %strlen %%pathlen %%path
    %endif

    %xdefine %%pathtok ""
    %assign %%i 1
    %rep %%pathlen
        %substr %%sub %%path %%i,1
        %ifidni %%sub,"."
            %xdefine %%pathtok %strcat(%%pathtok,"__")
        %elifidn %%sub,"/"
            %xdefine %%pathtok %strcat(%%pathtok,"_")
        %else
            %xdefine %%pathtok %strcat(%%pathtok,%%sub)
        %endif
        %assign %%i %%i+1
    %endrep
    %deftok %%pathtok %%pathtok
    %ifnidn __included_%+%%pathtok,1
        %xdefine __included_%[%%pathtok] 1
        retm %%path
    %else
        retm -1
    %endif
%endmacro

%rmacro include 1
    getPath %1
    %ifnidn __1,-1
        %include __1
    %endif
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

%define isPow2(x) (((x)&((x)-1))==0)
%define isStringDigit(x) %eval(x>='0' && x<='9')

%macro isNumber 1
    toStr %1
    %xdefine %%str __1
    %strlen %%len %%str
    %assign %%i 1
    %rep %%len
        %substr %%sub %%str %%i,1
        %if !(%%i==1&&%isidn(%%sub,"-")||isStringDigit(%%sub)||%isidn(%%sub,'.'))
            retm 0
            %exitrep
        %endif
        retm 1
        %assign %%i %%i+1
    %endrep
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
    newList __@,%{1:-1}
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

 ; char, currentMode, currentType
%macro updateStringMode 3
    isStringOpen %1
    %if __1
        %if %2
            retm (%3!=__2),%3
        %else
            retm 1,__2
        %endif
    %else
        retm %2,%3
    %endif
%endmacro

; findInToken(token1,token2)->index
%macro findInToken 2
    %defstr %%defStr1 %1
    %strlen %%defLen1 %%defStr1
    %assign %%isStr1 0

    %if %%defLen1 >= 2
        %substr %%firstCh %%defStr1 1
        %substr %%lastCh %%defStr1 %%defLen1
        %ifidni %%firstCh,"'"
            %ifidni %%lastCh,"'"
                %assign %%isStr1 1
            %endif
        %endif
        %if !%%isStr1
            %ifidni %%firstCh,'"'
                %ifidni %%lastCh,'"'
                    %assign %%isStr1 1
                %endif
            %endif
        %endif
    %endif

    %if %%isStr1
        %xdefine %%str1 %1
    %else
        %xdefine %%str1 %%defStr1
    %endif

    %defstr %%defStr2 %2
    %strlen %%defLen2 %%defStr2
    %assign %%isStr2 0
    %if %%defLen2 >= 2
        %substr %%firstCh %%defStr2 1
        %substr %%lastCh %%defStr2 %%defLen2
        %ifidni %%firstCh,"'"
            %ifidni %%lastCh,"'"
                %assign %%isStr2 1
            %endif
        %endif
        %if !%%isStr2
            %ifidni %%firstCh,'"'
                %ifidni %%lastCh,'"'
                    %assign %%isStr2 1
                %endif
            %endif
        %endif
    %endif
    %if %%isStr2
        %xdefine %%str2 %2
    %else
        %xdefine %%str2 %%defStr2
    %endif

    %assign %%stringMode 0
    %assign %%stringType 0

    %strlen %%lenStr1 %%str1
    %strlen %%lenStr2 %%str2
    %assign %%i 1
    %assign %%loopTimes (%%lenStr1-%%lenStr2)+1

    %if %%loopTimes<=0
        %xdefine __1 -1
        %xdefine __0 1
        %exitmacro
    %endif

    %assign %%found 0
    %rep %%loopTimes
        %if !%%stringMode && !%%found
            %substr %%sub %%str1 %%i,%%lenStr2
            %ifidni %%sub,%%str2
                %xdefine __1 %eval(%%i-1)
                %xdefine __0 1
                %assign %%found 1
            %endif
        %endif
        %if !%%found
            %substr %%ch %%str1 %%i,1
            %ifidni %%ch,"'"
                %if %%stringMode
                    %assign %%stringMode (%%stringType!=0)
                %else
                    %assign %%stringMode 1
                    %assign %%stringType 0
                %endif
            %else
            %ifidni %%ch,'"'
                %if %%stringMode
                    %assign %%stringMode (%%stringType!=1)
                %else
                    %assign %%stringMode 1
                    %assign %%stringType 1
                %endif
            %endif
            %endif
            %assign %%i %%i+1
        %endif
    %endrep

    %if !%%found
        %xdefine __1 -1
        %xdefine __0 1
    %endif
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



%macro joinBracketSplit 1
    newList %%items
    %assign %%stackcount 0
    %assign %%current 0
    %rep %0
        %if %%stackcount==0
            %assign %%current %%current+1
            listset %%items,%%current,%1
        %else
            listset %%items,%%current,listIndex(%%items,%%current)%+:%+%1
        %endif
        findInToken %1,"("
        %assign %%stackcount %%stackcount+__1
        findInToken %1,"["
        %assign %%stackcount %%stackcount+__1

        findInToken %1,"]"
        %assign %%stackcount %%stackcount-__1   
        findInToken %1,")"
        %assign %%stackcount %%stackcount-__1
        %rotate 1
    %endrep
    retm %%items
%endmacro

; splitToken(token, spliter) -> splited tokens
%macro splitToken 2
    toStr %1
    %xdefine %%token __1
    toStr %2
    %xdefine %%spliter __1
    %strlen %%len %%spliter

    newList %%parts

    %rep 100000
        findInToken %%token,%2
        %if __1 == -1
            listpush %%parts,%tok(%%token)
            %exitrep
        %endif
        %assign %%i __1
        subToken %%token,0,%%i
        listpush %%parts,__1
        
        subToken %%token,%%i+%%len
        %xdefine %%token __1
    %endrep
    retm %[%%parts]
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
%macro isTokenFloat 1
    toStr %1
    %xdefine %%str __1
    %strlen %%len %%str
    %assign %%dotCount 0
    %assign %%valid 1
    %assign %%i 1
    %rep %%len
        %substr %%sub %%str %%i,1
        %ifidn %%sub,'.'
            %assign %%dotCount %%dotCount+1
        %elif !isStringDigit(%%sub)
            %assign %%valid 0
        %endif
        %assign %%i %%i+1
    %endrep
    %if %%dotCount != 1 || !%%valid || %%len < 3
        retm 0
    %else
        retm 1
    %endif
%endmacro

%macro isTokenNum 1
    isTokenFloat %1
    %if __1
        retm 1
    %elifnum %1
        retm 1
    %elifstr %1
        retm 1
    %else
        retm 0
    %endif
%endmacro

%macro numType 1
    isTokenFloat %1
%endmacro
%define numSize(x) %eval((1 + ((x < -(1<<7)) || (x > (1<<7)-1)) * 1 + ((x < -(1<<15)) || (x > (1<<15)-1)) * 2 + ((x < -(1<<31)) || (x > (1<<31)-1)) * 4))

%macro tokenLen 1
    toStr %1
    %strlen %%len __1
    retm %%len
%endmacro

%macro isInputUnsigned 1-*
    %rep %0
        %if isRef(%1)
            removeIndex %1
            %if !signed(__1)
                retm 1
                %exitrep
            %endif
        %endif
        retm 0
    %rotate 1
    %endrep
%endmacro

%macro isInputSigned 1-*
    %rep %0
        %ifnum %1
            %if %1<0
                retm 1
            %endif
        %elif isRef(%1)
            removeIndex %1
            %if signed(__1)
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
    isTokenFloat %1
    %if __1
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
        updateStringMode %%sub, %%stringMode, %%stringType
        %assign %%stringMode __1
        %assign %%stringType __2
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
        updateStringMode %%sub, %%stringMode, %%stringType
        %assign %%stringMode __1
        %assign %%stringType __2
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

%define __macro_max(x,y) %eval((x>=y)*(x)+(x<y)*(y))
%define __macro_min(x,y) %eval( (x>=y)*(y)+(x<y)*(x))