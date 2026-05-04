; name,(key,item)...
%macro newDict 1-*
    newPool __%[%1]@dict@keys
    newList __%[%1]@dict@keys
    newList __%[%1]@dict@items
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

%define dictlen(name) poollen(__%+name%+@dict@keys)
%define dictkey(name,key) __%+name%+@dict@%+key
%define keyspool(name) __%+name%+@dict@keys

; name,key,data
%macro dictsetkey 3
    %if !poolin(__%[%1]@dict@keys,%2)
        %define __%[%1]@dict@%[%2] %3
        pooladd __%+%1%+@dict@keys,%2
        listpush __%+%1%+@dict@keys,%2
        newList __%+%1%+@dict@keys,%3
    %endif       
%endmacro