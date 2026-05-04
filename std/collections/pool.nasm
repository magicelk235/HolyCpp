; name,data
%macro newPool 1-*
    newList __%1@pool@list
    %if %0>1
        poolset %1,%{2:-1}
    %endif
%endmacro

; name,data
%macro poolset 1-*
    %xdefine %?name %1
    %rep %0-1
        %rotate 1
        pooladd %?name,%1
    %endrep
%endmacro

%define poollist(name) __%+name%+@pool@list
%define poollen(name) listlen(poollist(name))
%define poolin(name,item) %isnum(__%+name%+@pool@%+item)
%define ispool(name) %isnum(poollen(name))
; name,item
%macro pooladd 2
    %if !poolin(%1,%2)
        %assign __%[%1]@pool@%[%2] poollen(%1)
        listpush poollist(%1),%2
    %endif
%endmacro

; name,item
%macro poolrm 2
    %if poolin(%1,%2)
        %assign %?index __%[%1]@pool@%[%2]
        %undef __%[%1]@pool@%[%2] 
        %xdefine %?last listIndex(poollist(%1),poollen(%1)-1)
        listrm poollist(%1),%?index
        %assign __%1@pool@%?last poollen(%1)-1
    %endif
%endmacro

; name
%macro pooldelete 1
    %if ispool(%1)
        %assign %?i 0
        %rep poollen(%1)
            poolrm listIndex(poollist(%1),%?i)
            %assign %?i %?i+1
        %endrep
    %endif
%endmacro

; src,dest
%macro poolcopy 2
    %assign %?i 0
    %rep poollen(%1)
        pooladd %2,listIndex(poollist(%1),%?i)
        %assign %?i %?i+1
    %endrep
%endmacro

; src -> new copy
%macro poolnewcopy 1
    newPool %%copy
    poolcopy %1,%%copy
    retm %%copy
%endmacro