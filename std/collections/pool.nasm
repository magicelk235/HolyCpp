; creates a new pool
; newPool(name,data...)
%macro newPool 1-*
    %if ispool(%1)
        pooldelete %1
    %endif
    newList __pool@list@%1
    %if %0>1
        poolset %1,%{2:-1}
    %endif
%endmacro

; sets multiple elements in pool
; poolset(pool,data...)
%macro poolset 1-*
    %xdefine %?pool %1
    %rep %0-1
        %rotate 1
        pooladd %?pool,%1
    %endrep
%endmacro

%define poollist(poolName) merge(__pool@list@, poolName)
%define poollen(poolName) listlen(poollist(poolName))
%define poolin(poolName,item) %isnum(merge(merge(merge(__pool@, item), @), poolName))
%define ispool(poolName) %isnum(poollen(poolName))

; adds an element if it doesn't exist
; pooladd(pool,item)
%macro pooladd 2
    %if !poolin(%1,%2)
        %assign __pool@%[%2]@%[%1] poollen(%1)
        listpush poollist(%1),%2
    %endif
%endmacro

; removes an element
; poolrm(pool,item)
%macro poolrm 2
    %if poolin(%1,%2)
        %assign %?index __pool@%[%2]@%[%1]
        %undef __pool@%[%2]@%[%1]
        %xdefine %?last listIndex(poollist(%1),%eval(poollen(%1)-1))
        listrm poollist(%1),%?index
        %if %?index < poollen(%1)
            %assign __pool@%[%?last]@%[%1] %?index
        %endif
    %endif
%endmacro

; deletes pool
; pooldelete(pool)
%macro pooldelete 1
    %if ispool(%1)
        %assign %?i 0
        %rep poollen(%1)
            %undef __pool@%[listIndex(poollist(%1),%?i)]@%[%1]
            %assign %?i %?i+1
        %endrep
        listdelete poollist(%1)
    %endif
%endmacro

; copies all elements from src to dest
; poolcopy(src,dest)
%macro poolcopy 2
    %assign %?i 0
    %rep poollen(%1)
        pooladd %2,listIndex(poollist(%1),%?i)
        %assign %?i %?i+1
    %endrep
%endmacro

; creates a new copy of a pool
; poolnewcopy(src)
%macro poolnewcopy 1
    newPool %%copy
    poolcopy %1,%%copy
    retm %%copy
%endmacro

; converts pool to a tuple
; pooltotuple(pool) -> tuple
%macro pooltotuple 1
    %assign %?i 1
    %xdefine __1 listIndex(poollist(%1),0)
    %rep %eval(poollen(%1)-1)
        %xdefine __1 __1%+,%+listIndex(poollist(%1),%?i)
        %assign %?i %?i+1
    %endrep
%endmacro