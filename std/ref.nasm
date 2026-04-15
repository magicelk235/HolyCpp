%assign arraySizeOffset 8
; set a ref to a float
; setFloat(ref,value)
%macro setFloat 2
    %if ! isReg(%1)
        splitIndex %1
        %xdefine __float_%[__1] %2
    %endif
%endmacro

; makes a new ref that store size,addr,depth,float,times
; newRef(ref's name,size,addr,depth,float,times)
%macro newRef 6
    %assign __size_%1 %2 ;-> __size_name
    %xdefine __addr_%1 %3; -> __addr_name
    %assign __depth_%1 %4
    %assign __float_%1 %5
    %assign __times_%1 %6
    %xdefine __ref_%1 1
%endmacro

%define depth(name) __depth_ %+ name
%define times(name) __times_ %+ name
%define float(name) __float_ %+ name
%define addr(name) __addr_ %+ name
%define isRef(x) %isnum(__ref_%+x)
%define isDirectRef(x) %isidn(__ref_ %+ x,1)

; search for [ at start
; isDirectMemory(token)
%macro isDirectMemory 1
    subToken %1,0,1
    %ifnidn __1,[
        retm 0
        %exitmacro
    %endif
    findInToken %1,:
    retm %eval(__1==-1)
%endmacro

; load ref's address
; lra(ref,ignored,use,depthOffset)
%macro lra 4
    retm 0
    %if isDirectRef(%1)
        %assign %%depth depth(%1)-%4
        %if %%depth>0
            %if isReg(%3)
                %xdefine r reg(8,%[group(%3)])
            %else
                resr %2
            %endif
            omov r,[addr(%1)]
            %rep %%depth-1
                omov qword r,[r]
            %endrep
            retm r
        %else
            retm addr(%1)
        %endif
    %endif
%endmacro

;  a ref or arrays address
; addrOf(ref,ignored,used,depthOffset)
%macro addrOf 4
    lra %1,%2,%3,%4
    %ifidn __1,0
        getIndexOffset %1,%2,%3,%4
    %endif
%endmacro

; ref/array,dest,depth
%macro lea 2-3
    %if %0==2
        %assign %%depthOffset 0
    %else
        %assign %%depthOffset %3
    %endif
    addrOf %1,"",%2,%%depthOffset
    %if isReg(%2)
        %ifnidn %2,__1
            lea %2,[__1]
        %endif
    %elif isRef(%2)
        %xdefine %%addr __1
        resr %%addr
        lea r,[%%addr]
        mov %2,r
    %else
        lea %2,[%1]
    %endif
    resetOld
%endmacro

; makes a new global .bss variable
; newgb(name,size,times,depth)
%macro newgb 4
    section .bss
    %assign %%size %2
    %if %4>0
        %assign %%size 8
    %endif
    %if %3==1
        __global_label_%1 resb %2
        section .text
    %else
        __global_label_%1 resb arraySizeOffset
        resb %3*%%size
        section .text
        omov qword [__global_label_%1],%3*%%size
    %endif
    retm __global_label_%1
%endmacro

; makes a new global .data variable
; newgd(name,size,times,depth,data,section)
%macro newgd 6
    section %6
    %xdefine %%size %2
    %if %4>0
        %define %%size 8
    %endif
    %if %3==1
        %if %%size==1
            __global_label_%1 db %5
        %elif %%size==2
            __global_label_%1 dw %5
        %elif %%size==4
            __global_label_%1 dd %5
        %else
            __global_label_%1 dq %5
        %endif
    %else
        %ifstr %5
            tokenCount %5,"\"
            %if __1!=0
                %assign %%len %3*%2-__1
                tokenCount %5,"\\"
                __global_label_%1 dq %eval(%%len+__1)
                %strlen %%len %5
                %assign %%special 0
                %assign %%i 1
                %rep %%len
                    %substr %%char %5 %%i
                    %if %%special
                        %if %%char == "n"
                            db 10
                        %elif %%char == "a"
                            db 7
                        %elif %%char == "b"
                            db 8
                        %elif %%char == "v"
                            db 11
                        %elif %%char == "f"
                            db 12
                        %elif %%char == "r"
                            db 13
                        %elif %%char == "\"
                            db 92
                        %elif %%char == "0"
                            db 0
                        %endif
                        %assign %%special 0
                    %else
                        %if %%char == "\"
                            %assign %%special 1
                        %else
                            db %%char
                        %endif
                    %endif
                    %assign %%i %%i+1
                %endrep

            %else
                __global_label_%1 dq %3*%2
                db %5
            %endif
            db 0
        %else
            __global_label_%1 dq %3*%2
            %push
            splitArrayToTokens %5
            %assign %%i 1
            %rep %$__0
                %if %%size==1
                    db %[%$__%+%%i]
                %elif %%size==2
                    dw %[%$__%+%%i]
                %elif %%size==4
                    dd %[%$__%+%%i]
                %else
                    dq %[%$__%+%%i]
                %endif
                %assign %%i %%i+1
            %endrep
            %pop
        %endif
    %endif
    section .text
    retm __global_label_%1
%endmacro

; new(name)
%macro new 1-*

    %assign %%stackcount 0
    %assign %%current 0
    %rep %0
        %if %%stackcount==0
            %assign %%current %%current+1
            %xdefine %%n_%[%%current] %1
        %else
            %xdefine %%n_%[%%current] %%n_%[%%current]%+:%+%1
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

    %assign %%count %%current
    %assign %%current 1
    %rep %%count
        %xdefine %%name %%n_%[%%current]
        findInToken %%name,=
        %assign %%startData %eval(__1!=-1)
        %if %%startData
            %assign %%startDataIndex __1+1
            subToken %%name,%%startDataIndex
            %xdefine %%data __1
            subToken %%name,0,%eval(%%startDataIndex-1)
            %xdefine %%name __1
        %endif

        ; size search for "local,global.."
        findInToken %%name,"global "
        %if __1 != -1
            replaceToken %%name,"global ",""
            %xdefine %%name __1
            %define %%scope "g"
        %else
        findInToken %%name,"local "
        %if __1 != -1
            replaceToken %%name,"local ",""
            %xdefine %%name __1
            %define %%scope "l"
        %else
        findInToken %%name,"tbp "
        %if __1 != -1
            replaceToken %%name,"tbp ",""
            %xdefine %%name __1
            %define %%scope "tbp"
        %else
        findInToken %%name,"tsp "
        %if __1 != -1
            replaceToken %%name,"tsp ",""
            %xdefine %%name __1
            %define %%scope "tsp"
        %else
        findInToken %%name,"const "
        %if __1 != -1
            replaceToken %%name,"const ",""
            %xdefine %%name __1
            %define %%scope "c"
        %else
        findInToken %%name,"arg "
        %if __1 != -1
            replaceToken %%name,"arg ",""
            %xdefine %%name __1
            %define %%scope "a"
        %elif inProc
            %define %%scope "l"
        %else
            %define %%scope "g"
        %endif
        %endif
        %endif
        %endif
        %endif
        %endif

        ; size search for "byte,word.."
        %assign %%size 1
        findInToken %%name,"byte "
        %if __1 != -1
            replaceToken %%name,"byte ",""
            %xdefine %%name __1
            %assign %%size 1
        %else
        findInToken %%name,"qword "
        %if __1 != -1
            replaceToken %%name,"qword ",""
            %xdefine %%name __1
            %assign %%size 8
        %else
        findInToken %%name,"dword "
        %if __1 != -1
            replaceToken %%name,"dword ",""
            %xdefine %%name __1
            %assign %%size 4
        %else
        findInToken %%name,"word "
        %if __1 != -1
            replaceToken %%name,"word ",""
            %xdefine %%name __1
            %assign %%size 2
        %endif
        %endif
        %endif
        %endif

        %assign %%float 0
        findInToken %%name,.
        %if __1!=-1
            replaceToken %%name,.,""
            %xdefine %%name __1
            %assign %%float 1
        %endif

        ; search for [] if is an array
        findPare %%name,[,]
        %if __1 != -1
            %assign %%startIndex __1
            %assign %%stopIndex __2
            subToken %%name,%eval(%%startIndex+1),%%stopIndex

            %if isEmpty(__1)
                %ifstr %%data
                    %strlen %%times %%data
                %else
                    tokenCount %%data,:
                    %assign %%times __1+1
                %endif
            %else
                %assign %%times __1
            %endif
            subToken %%name,%%startIndex,-1
            replaceToken %%name,__1,""
            %xdefine %%name __1
        %else
            %assign %%times 1
        %endif

        %xdefine %%setName %%name

        ; pointer depth searches for @
        tokenCount %%name,@
        %assign %%depth __1

        replaceToken %%name,@,""
        %xdefine %%name __1


        %if %%scope=="c"
            newgd %%name,%%size,%%times,%%depth,%%data,.rdata
        %elif %%scope=="g"
            %if %%startData
                newgd %%name,%%size,%%times,%%depth,%%data,.data
            %else
                newgb %%name,%%size,%%times,%%depth
            %endif
        %elif %%scope=="l"
            newl %%name,%%size,%%times,%%depth
        %elif %%scope=="a"
            arg %%name,%%size,%%times,%%depth
        %elif %%scope=="tbp"
            newtbp %%name,%%size,%%times,%%depth
        %elif %%scope=="tsp"
            newtsp %%name,%%size,%%times,%%depth
        %endif

        newRef %%name,%%size,__1,%%depth,%%float,%%times
        %if %%startData
            %if %%scope == "l"
                set %%setName=%%data
            %elif %%scope == "a"
                cmp qword [addr(argc)],%eval(args(procName)-8)
                jge .enough %+ %[args(procName)]
                set %%setName = %%data
                .enough %+ %[args(procName)]:
            %endif
        %endif
    %assign %%current %%current+1
    %endrep
%endmacro

; set
%macro set 1-*
    %xdefine %%data %1
    %rotate 1
    %rep %0-1
        %xdefine %%data %%data %+ : %+ %1
        %rotate 1
    %endrep

    findInToken %%data,=
    %assign %%startDataIndex __1
    subToken %%data,0,%%startDataIndex
    %xdefine %%name __1
    subToken %%data,%eval(%%startDataIndex+1)
    eval __1
    mov %%name,__1
    endEval
%endmacro