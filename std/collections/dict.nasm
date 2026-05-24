; creates a new dictionary
; newDict(name,(key,value)...)
%macro newDict 1-*
    %if isdict(%1)
        dictdelete %1
    %endif
    newPool __dict@keys@%[%1]
    %if %0>1
        dictset %1,%{2:-1}
    %endif
%endmacro

; sets multiple (key,value) pairs
; dictset(dict,(key,value)...)
%macro dictset 1-*
    %xdefine %?dict %1
    %rotate 1
    %rep (%0-1)/2
        dictsetkey %?dict,%1,%2
        %rotate 2
    %endrep
%endmacro

%define dictkeyspool(dictName) merge(__dict@keys@, dictName)
%define dictkeyslist(dictName) poollist(dictkeyspool(dictName))
%define dictlen(dictName) poollen(dictkeyspool(dictName))
%define indict(dictName,key) poolin(dictkeyspool(dictName),key)
%define dictkey(dictName,key) merge(merge(merge(__dict@, key), @), dictName)
%define keyspool(dictName) merge(__dict@keys@, dictName)
%define isdict(dictName) %isnum(dictlen(dictName))

; sets a (key,value) pair
; dictsetkey(dict,key,data)
%macro dictsetkey 3
    %xdefine __dict@%[%2]@%[%1] %3
    %if !indict(%1,%2)
        pooladd dictkeyspool(%1),%2
    %endif
%endmacro

; removes a (key,value) pair
; dictrmkey(dict,key)
%macro dictrmkey 2
    %if indict(%1,%2)
        %undef __dict@%[%2]@%[%1]
        poolrm dictkeyspool(%1),%2
    %endif
%endmacro

; deletes dictionary
; dictdelete(dict)
%macro dictdelete 1
    %if isdict(%1)
        %assign %?i 0
        %rep dictlen(%1)
            %undef __dict@%[listIndex(dictkeyslist(%1),%?i)]@%[%1]
            %assign %?i %?i+1
        %endrep
        pooldelete dictkeyspool(%1)
    %endif
%endmacro

; copies all pairs from src to dest
; dictcopy(src,dest)
%macro dictcopy 2
    %assign %?i 0
    %rep dictlen(%1)
        %xdefine %?key listIndex(dictkeyslist(%1),%?i)
        dictsetkey %2,%?key,dictkey(%1,%?key)
        %assign %?i %?i+1
    %endrep
%endmacro

; creates a new copy of a dictionary
; dictnewcopy(src)
%macro dictnewcopy 1
    newDict %%copy
    dictcopy %1,%%copy
    retm %%copy
%endmacro

; prints dictionary pairs as warnings
; dictwarning(name)
%macro dictwarning 1
    %assign %?i 0
    %rep dictlen(%1)
        %xdefine %?key listIndex(dictkeyslist(%1),%?i)
        %warning "  " %?key ":" dictkey(%1,%?key)
        %assign %?i %?i+1
    %endrep
%endmacro