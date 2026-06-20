; setBlockType(type)
%macro setBlockType 1
    %xdefine %$blockType %1
%endmacro

; if(expression)
%macro if 1-*
    %xdefine %?expression %1
    %rotate 1
    %rep %0-1
        %xdefine %?expression %?expression %+ : %+ %1
        %rotate 1
    %endrep
    %push
    setBlockType "if"
    %$ifcheck:
    %assign %$blockCount 0
    eval %?expression
    mov r15,__1
    endEval
    cmp r15,false
    je %$next%[%$blockCount]
%endmacro

; else
%macro else 0
    jmp %$end
    %$next%[%$blockCount]:
    %assign %$blockCount %$blockCount+1
%endmacro

; elif(expression)
%macro elif 1-*
    else
    %xdefine %?expression %1
    %rotate 1
    %rep %0-1
        %xdefine %?expression %?expression %+ : %+ %1
        %rotate 1
    %endrep

    eval %?expression
    mov r15,__1
    endEval
    cmp r15,false
    je %$next%[%$blockCount]
%endmacro 

; endif
%macro endif 0
    %$next%[%$blockCount]:
    jmp %$end
    %$end:
    %pop
%endmacro

; jump to end of enclosing block
; break
%macro break 0
    jmp %$end
%endmacro

; jump to check of enclosing loop
; continue
%macro continue 0
    jmp %$check
%endmacro

; while(expression)
%macro while 1-*
    %xdefine %?expression %1
    %rotate 1
    %rep %0-1
        %xdefine %?expression %?expression %+ : %+ %1
        %rotate 1
    %endrep
    %push
    setBlockType "while"
    %assign %$blockCount 0
    %$check:
    resetOld
    eval %?expression
    mov r15,__1
    endEval
    cmp r15,false
    je %$end
%endmacro

; endwhile
%macro endwhile 0
    jmp %$check
%endmacro

; for(init, condition, step)
%macro for 1-*
    %assign %?stackcount 0
    %assign %?current 0
    %rep %0
        %if %?stackcount==0
            %assign %?current %?current+1
            %xdefine %?e_%[%?current] %1
        %else
            %xdefine %?e_%[%?current] %?e_%[%?current]%+:%+%1
        %endif
        findInToken %1,"("
        %assign %?stackcount %?stackcount+__1
        findInToken %1,"["
        %assign %?stackcount %?stackcount+__1

        findInToken %1,"]"
        %assign %?stackcount %?stackcount-__1   
        findInToken %1,")"
        %assign %?stackcount %?stackcount-__1
        %rotate 1
    %endrep

    %?e_1
    %push
    %xdefine %$instruction %?e_3
    setBlockType "for"
    %assign %$blockCount 0
    %$check:
    resetOld
    eval %?e_2
    mov r15,__1
    endEval
    cmp r15,false
    je %$end
%endmacro

; endfor
%macro endfor 0
    %$instruction
    jmp %$check
%endmacro

; dowhile(expression)
%macro dowhile 1-*
    %xdefine %?expression %1
    %rotate 1
    %rep %0-1
        %xdefine %?expression %?expression %+ : %+ %1
        %rotate 1
    %endrep
    %push
    setBlockType "dowhile"
    %assign %$blockCount 0
    %xdefine %$expression %?expression
    %$check:
%endmacro

; enddowhile
%macro enddowhile 0
    eval %$expression
    mov r15,__1
    endEval
    cmp r15,false
    jne %$check
%endmacro
; declare proc with typed args and optional return count
; func(name(type arg, ...) > ?outs)
%macro func 1-*
    %rotate -1
    findInToken %1,>
    %if __1 != -1
        %assign %?startOutputIndex __1+1
        subToken %1,%?startOutputIndex
        %assign %?outs __1
        subToken %1,0,%eval(%?startOutputIndex-2)
        %xdefine %?lastArg __1
    %else
        subToken %1,0,-2
        %xdefine %?lastArg __1
        %assign %?outs 0
    %endif
    %rotate 1
    findInToken %?lastArg,"("
    %if __1!=-1
        subToken %?lastArg,%eval(__1+1),-1
        %xdefine %?lastArg __1
    %endif

    findInToken %1,"("
    %assign %?startArgsIndex __1
    subToken %1,(%?startArgsIndex+1)
    %xdefine %?arg1 __1
    subToken %1,0,(%?startArgsIndex)
    %xdefine %?name __1

    proc %?name,%?outs
    %if %0==1
        %if !isEmpty(%?lastArg)
            splitToken %?lastArg," "
            %xdefine %?argType listIndex(__1,0)
            %xdefine %?argName listIndex(__1,1)
            new %?argType, arg %?argName
        %endif
    %else
        splitToken %?arg1," "
        %xdefine %?argType listIndex(__1,0)
        %xdefine %?argName listIndex(__1,1)
        new %?argType, arg %?argName
        %rep %0-2
            %rotate 1
            splitToken %1," "
            %xdefine %?argType listIndex(__1,0)
            %xdefine %?argName listIndex(__1,1)
            new %?argType, arg %?argName
        %endrep
        splitToken %?lastArg," "
        %xdefine %?argType listIndex(__1,0)
        %xdefine %?argName listIndex(__1,1)
        new %?argType, arg %?argName
    %endif

    %assign __proc@clean@%[%?name] __macro_max(args(%?name) - outs(%?name),0)
%endmacro

; close current block, dispatches to endproc/endif/endwhile/endfor/enddowhile
; end
%macro end 0
    end%+%tok(%$blockType)
%endmacro