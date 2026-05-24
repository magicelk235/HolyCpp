; creates a new list
; newList(name,data...)
%macro newList 1-*
    %if islist(%1)
        listdelete %1
    %endif
    %assign __list@len@%1 %0-1
    %if %0>1
        listset %{1:-1}
    %endif
%endmacro

; sets elements from arguments
; listset(list,data...)
%macro listset 1-*
    %xdefine %?list %1
    %assign %?i 0
    %rep %0-1
        %rotate 1
        listsetindex %?list,%?i,%1
        %assign %?i %?i+1
    %endrep
%endmacro

%define listlen(listName) merge(__list@len@, listName)
%define listIndex(listName,i) merge(merge(merge(__list@, i), @), listName)
%define islist(listName) %isnum(listlen(listName))
%define listpeek(listName) listIndex(listName,listIndex)

; sets element at index
; listsetindex(list,index,data)
%macro listsetindex 3
    %xdefine __list@%2@%1 %3
    %if %2>=listlen(%1)
        %assign __list@len@%1 %2+1
    %endif
%endmacro

; appends element to list
; listpush(list,data)
%macro listpush 2
    %assign %?index listlen(%1)
    listsetindex %1,%?index,%{2:-1}
%endmacro

; removes and returns last element
; listpop(list,dest) -> last element
%macro listpop 2
    %assign %?index listlen(%1)-1
    retm listIndex(%1,%?index)
    listrm %1,%?index
%endmacro

; sets last element
; listsetpeek(list,data)
%macro listsetpeek 2
    %assign %?index listlen(%1)-1
    listsetindex %?index,%2
%endmacro

; remove and shifts
; listrmsh(list,index)
%macro listrmsh 2
    %assign %?i %2
    %rep listlen(%1)-%?i-1
        listsetindex %1,%?i,listIndex(%1,%eval(%?i+1))
    %endrep
    %assign __list@len@%[%1] listlen(%1)-1
%endmacro

; removes element at index no shift
; listrm(list,index)
%macro listrm 2
    %assign %?i %2
    %assign %?lastidx listlen(%1)-1
    %assign __list@len@%[%1] %?lastidx
    listsetindex %1,%?i,listIndex(%1,%?lastidx)
    %undef __list@%[%?lastidx]@%[%1]
    %assign __list@len@%[%1] %?lastidx
%endmacro

; prints list elements as warnings
; listwarning(list)
%macro listwarning 1
    %assign %?i 0
    %rep listlen(%1)
        %warning listIndex(%1,%?i)
        %assign %?i %?i+1
    %endrep
%endmacro

; converts list to a tuple
; listToTuple(list) -> tuple
%macro listToTuple 1
    %assign %?i 1
    %xdefine __1 listIndex(%1,0)
    %rep %eval(listlen(%1)-1)
        %xdefine __1 merge(merge(__1, ,), listIndex(%1,%?i))
        %assign %?i %?i+1
    %endrep
%endmacro

; deletes list and frees defines
; listdelete(list)
%macro listdelete 1
    %if islist(%1)
        %assign %?i 1
        %rep listlen(%1)
            %undef __list@%[%?i]@%[%1]
        %endrep
        %undef __list@len@%[%1]
    %endif
%endmacro

; copies elements from src to dest
; listcopy(src,dest)
%macro listcopy 2
    %assign %?i 0
    %rep listlen(%1)
        listsetindex %2,%?i,listIndex(%1,%?i)
        %assign %?i %?i+1
    %endrep
%endmacro

; creates a new copy of a list
; listnewcopy(src) -> newList
%macro listnewcopy 1
    newList %%copy
    listcopy %1,%%copy
    retm %%copy
%endmacro