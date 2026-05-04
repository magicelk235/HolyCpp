; name,(key,item)...
%macro newDict 1-*
    newPool __%[%1]@dict@keys
    %if %0>1
        dictset %1,%{2:-1}
    %endif
%endmacro

; name,(key,item)...
%macro dictset 1-*
    %xdefine %?name %1
    %rotate 1
    %rep (%0-1)/2
        dictsetkey %?name,%1,%2
        %rotate 2
    %endrep
%endmacro

%define dictkeyspool(name) __%+%%name%+@dict@keys
%define dictkeyslist(name) poollist(dictkeyspool(name))
%define dictlen(name) poollen(dictkeys(name))
%define indict(name,key) poolin(dictkeyspool(name),key)
%define dictkey(name,key) __%+name%+@dict@%+key
%define keyspool(name) __%+name%+@dict@keys
%define isdict(name) %isnum(dictlen(name))

; name,key,data
%macro dictsetkey 3
    %if !indict(%1,%2)
        %define __%[%1]@dict@%[%2] %3
        pooladd dictkeyspool(%1),%2
    %endif       
%endmacro

; name,key
%macro dictrmkey 2
    %if indict(%1,%2)
        %undef __%[%1]@dict@%[%2]
        poolrm %2
    %endif       
%endmacro

; name
%macro dictdelete 1
    %if isDict(%1)
        %assign %?i 0
        %rep dictlen(%1)
            undef __%%1@dict@%listIndex(dictkeyslist(%1),%?i)
        %endrep
        pooldelete dictkeyspool(%1)
    %endif
%endmacro