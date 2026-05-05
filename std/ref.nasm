; makes a new ref that store size,addr,depth,type,signed,shape...
; newRef(name, addr, type, depth, shape...)
%macro newRef 5-*
    %xdefine __%1@ref@addr %2
    %xdefine __%1@ref@type %3
    %assign __%1@size classSize(%3)
    %assign __%1@ref@depth %4
    %assign __ref@ref@%1 1
    %xdefine refName %1

    %assign __%1@ref@totalSize 8*(%4>0)+size(%1)*(%4<=0) ; 8 byte pointer or real size
    newList __%1@ref@shape
    %rotate 4
    %rep %0-4
        %assign __%[refName]@ref@totalSize totalSize(refName)*%1
        listpush __%[refName]@ref@shape, %1
        %rotate 1
    %endrep

    %ifnmacro %[refName]
        %macro %[refName] 1-*
            set %?%{1:-1}
        %endmacro
    %endif

    %rep depth(%[refName])
        %xdefine refName @%+refName
        %ifnmacro %[refName]
            %macro %[refName] 1-*
            set %?%{1:-1}
            %endmacro
        %endif
    %endrep

%endmacro

%define totalSize(name) __ %+ name %+ @ref@totalSize
%define type(name) __ %+ name %+ @ref@type
%define depth(name) __ %+ name %+ @ref@depth
%define shape(name) __ %+ name %+ @ref@shape
%define addr(name) __ %+ name %+ @ref@addr
%define signed(name) %isidn(classSigned(%[type(name)]),1)
%define isRef(x) %isnum(__ref@ref@%+x)
%define isDirectRef(x) %isidn(__ref@ref@%+x, 1)

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
        %assign %?depth depth(%1)-%4
        %if %?depth>0
            %if isReg(%3)
                %xdefine r reg(8,%[group(%3)])
            %else
                resr %2
            %endif
            omov r,[addr(%1)]
            %rep %?depth-1
                omov qword r,[r]
            %endrep
            retm r
        %else
            retm addr(%1)
        %endif
    %endif
%endmacro

;  a ref or arrays address or direct mem
; addrOf(ref,ignored,used,depthOffset)
%macro addrOf 4
    isDirectMemory %1
    %if __1
        subToken %1,1,-2
    %else
        lra %1,%2,%3,%4
        %ifidn __1,0
            getIndexOffset %1,%2,%3,%4
        %endif
    %endif
%endmacro

%assign inlea 0

%macro olea 2
    %if inlea
        lea %1,%2
    %else
        lea %1,%2,0,0
    %endif
%endmacro

; ref/array,dest,depth
%macro lea 2-4
    %if %0==4
        lea %1,%2
        %exitmacro
    %endif

    %assign inlea 1
    %if %0==2
        %assign %?depthOffset 0
    %else
        %assign %?depthOffset %3
    %endif
    addrOf %1,"",%2,%?depthOffset
    %if isReg(%2)
        %ifnidn %2,__1
            lea %2,[__1]
        %endif
    %elif isRef(%2)
        %xdefine %?addr __1
        resr %?addr
        lea r,[%?addr]
        mov %2,r
    %else
        lea %2,[%1]
    %endif
    resetOld
    %assign inlea 0
%endmacro

; makes a new global .bss variable
; newgb(name,size,times,depth)
%macro newgb 4
    section .bss
    %assign %?size %2
    %if %4>0
        %assign %?size 8
    %endif
    %if %3==1
        __global_label_%1 resb %2
    %else
        __global_label_%1 resb %3*%?size
    %endif
    section .text
    retm __global_label_%1
%endmacro

; makes a new global .data variable
; newgd(name,size,times,depth,data,section)
%macro newgd 6
    section %6
    %xdefine %?size %2
    %if %4>0
        %define %?size 8
    %endif
    %if %3==1
        %if %?size==1
            __global_label_%1 db %5
        %elif %?size==2
            __global_label_%1 dw %5
        %elif %?size==4
            __global_label_%1 dd %5
        %else
            __global_label_%1 dq %5
        %endif
    %else
        %ifstr %5
            tokenCount %5,"\"
            %if __1!=0
                %strlen %?len %5
                %assign %?special 0
                %assign %?i 1
                __global_label_%1:
                %rep %?len
                    %substr %?char %5 %?i
                    %if %?special
                        %if %?char == "n"
                            db 10
                        %elif %?char == "a"
                            db 7
                        %elif %?char == "b"
                            db 8
                        %elif %?char == "v"
                            db 11
                        %elif %?char == "f"
                            db 12
                        %elif %?char == "r"
                            db 13
                        %elif %?char == "\"
                            db 92
                        %elif %?char == "0"
                            db 0
                        %endif
                        %assign %?special 0
                    %else
                        %if %?char == "\"
                            %assign %?special 1
                        %else
                            db %?char
                        %endif
                    %endif
                    %assign %?i %?i+1
                %endrep

            %else
                __global_label_%1 db %5
            %endif
            db 0
        %else
            __global_label_%1:
            %push
            splitArrayToTokens %5
            %assign %?i 1
            %rep %$__0
                %if %?size==1
                    db %[%$__%+%?i]
                %elif %?size==2
                    dw %[%$__%+%?i]
                %elif %?size==4
                    dd %[%$__%+%?i]
                %else
                    dq %[%$__%+%?i]
                %endif
                %assign %?i %?i+1
            %endrep
            %pop
        %endif
    %endif
    section .text
    retm __global_label_%1
%endmacro

%macro int 1-*
%endmacro

; new(name)
%macro new 1-*
    joinBracketSplit %1
    %define %?expression listIndex(__1,0)

    %xdefine %?name %?n_%[%?current]
    findInToken %?name,= ; split start data
    %assign %?startData %eval(__1!=-1)
    %if %?startData
        %assign %?startDataIndex __1+1
        subToken %?name,%?startDataIndex
        %xdefine %?data __1
        subToken %?name,0,%eval(%?startDataIndex-1)
        %xdefine %?name __1
    %endif

    ; size searches for scope
    findInToken %?name,"global "
    %if __1 != -1
        replaceToken %?name,"global ",""
        %xdefine %?name __1
        %define %?scope "g"
    %else
    findInToken %?name,"local "
    %if __1 != -1
        replaceToken %?name,"local ",""
        %xdefine %?name __1
        %define %?scope "l"
    %else
    findInToken %?name,"tbp "
    %if __1 != -1
        replaceToken %?name,"tbp ",""
        %xdefine %?name __1
        %define %?scope "tbp"
    %else
    findInToken %?name,"tsp "
    %if __1 != -1
        replaceToken %?name,"tsp ",""
        %xdefine %?name __1
        %define %?scope "tsp"
    %else
    findInToken %?name,"const "
    %if __1 != -1
        replaceToken %?name,"const ",""
        %xdefine %?name __1
        %define %?scope "c"
    %else
    findInToken %?name,"arg "
    %if __1 != -1
        replaceToken %?name,"arg ",""
        %xdefine %?name __1
        %define %?scope "a"
    %elif inProc
        %define %?scope "l"
    %else
        %define %?scope "g"
    %endif
    %endif
    %endif
    %endif
    %endif
    %endif

    %assign %?signed 1
    ; size searches for size
    %assign %?size 1
    %assign %?float 0
    findInToken %?name,"float "
    %if __1 != -1
        replaceToken %?name,"float ",""
        %xdefine %?name __1
        %assign %?size 8
        %assign %?float 1
    %else
    findInToken %?name,"int "
    %if __1 != -1
        replaceToken %?name,"int ",""
        %xdefine %?name __1
        %assign %?size 4
        %assign %?signed 1
    %else
    findInToken %?name,"long "
    %if __1 != -1
        replaceToken %?name,"long ",""
        %xdefine %?name __1
        %assign %?size 8
        %assign %?signed 1
    %else
    findInToken %?name,"char "
    %if __1 != -1
        replaceToken %?name,"char ",""
        %xdefine %?name __1
        %assign %?size 1
        %assign %?signed 0
    %else
    findInToken %?name,"bool "
    %if __1 != -1
        replaceToken %?name,"bool ",""
        %xdefine %?name __1
        %assign %?size 1
        %assign %?signed 0
    %else
    findInToken %?name,"short "
    %if __1 != -1
        replaceToken %?name,"short ",""
        %xdefine %?name __1
        %assign %?size 2
    %else
    findInToken %?name,"byte "
    %if __1 != -1
        replaceToken %?name,"byte ",""
        %xdefine %?name __1
        %assign %?size 1
    %else
    findInToken %?name,"qword "
    %if __1 != -1
        replaceToken %?name,"qword ",""
        %xdefine %?name __1
        %assign %?size 8
    %else
    findInToken %?name,"dword "
    %if __1 != -1
        replaceToken %?name,"dword ",""
        %xdefine %?name __1
        %assign %?size 4
    %else
        findInToken %?name,"word "
        %if __1 != -1
            replaceToken %?name,"word ",""
            %xdefine %?name __1
            %assign %?size 2
        %endif
        %endif
        %endif
        %endif
        %endif
        %endif
        %endif
        %endif
        %endif
        %endif

        findInToken %?name,~
        %if __1!=-1
            replaceToken %?name,~,""
            %xdefine %?name __1
            %assign %?signed 0
        %endif

        ; search for [] if is an array
        findPare %?name,[,]
        %if __1 != -1
            %assign %?startIndex __1
            %assign %?stopIndex __2
            subToken %?name,%eval(%?startIndex+1),%?stopIndex

            %if isEmpty(__1)
                %ifstr %?data
                    %strlen %?times %?data
                %else
                    tokenCount %?data,:
                    %assign %?times __1+1
                %endif
            %else
                %assign %?times __1
            %endif
            subToken %?name,%?startIndex,-1
            replaceToken %?name,__1,""
            %xdefine %?name __1
        %else
            %assign %?times 1
        %endif

        %xdefine %?setName %?name

        ; pointer depth searches for @
        tokenCount %?name,@
        %assign %?depth __1

        replaceToken %?name,@,""
        %xdefine %?name __1


        %if %?scope=="c"
            newgd %?name,%?size,%?times,%?depth,%?data,.rdata
        %elif %?scope=="g"
            %if %?startData
                newgd %?name,%?size,%?times,%?depth,%?data,.data
            %else
                newgb %?name,%?size,%?times,%?depth
            %endif
        %elif %?scope=="l"
            newl %?name,%?size,%?times,%?depth
        %elif %?scope=="a"
            arg %?name,%?size,%?times,%?depth
        %elif %?scope=="tbp"
            newtbp %?name,%?size,%?times,%?depth
        %elif %?scope=="tsp"
            newtsp %?name,%?size,%?times,%?depth
        %endif

        newRef %?name,%?size,__1,%?depth,%?float,%?times,%?signed
        %if %?startData
            %if %?scope == "l"
                set %?setName=%?data
            %elif %?scope == "a"
                cmp qword [addr(argc)],%eval(args(procName)-8)
                jge .enough %+ %[args(procName)]
                set %?setName = %?data
                .enough %+ %[args(procName)]:
            %endif
        %endif
    %assign %?current %?current+1
    %endrep
%endmacro

; set
%macro set 1-*
    %xdefine %?data %1
    %rotate 1
    %rep %0-1
        %xdefine %?data %?data %+ : %+ %1
        %rotate 1
    %endrep

    clearSpaces %?data
    %xdefine %?data __1

    findInToken %?data,=
    %if __1!=-1
        %assign %?startDataIndex __1
        subToken %?data,%eval(%?startDataIndex+1)
        %xdefine %?expression __1

        subToken %?data,%eval(%?startDataIndex-1),%?startDataIndex
        %xdefine %?sub __1

        isOperator %str(%?sub)
        %if __1
            subToken %?data,0,%eval(%?startDataIndex-1)
            %xdefine %?name __1
            %xdefine %?expression (%?expression)%+%?sub%+%?name
        %else
            subToken %?data,0,%?startDataIndex
            %xdefine %?name __1
        %endif
        eval %?expression
        mov %?name,__1
        endEval
    %else
            findInToken %?data,"++"
    %if __1 != -1
        subToken %?data,0,__1
        lxd __1,""
        inc sizename(__2) __1
    %else
        findInToken %?data,"--"
        %if __1 != -1
            subToken %?data,0,__1
            lxd __1,""
            dec sizename(__2) __1
        %endif
    %endif
    %endif
%endmacro