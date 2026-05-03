; name,data
%macro newList 1-*
    %assign __%[%1]@list@len %0-1
    %if %0>1
        listset %{1:-1}
    %endif
%endmacro

; name,data
%macro listset 1-*
    %xdefine %%name %1
    %assign %%i 0
    %rep %0-1
        %rotate 1
        listsetindex %%name,%%i,%1
        %assign %%i %%i+1
    %endrep
%endmacro

%define listlen(name) __%+name%+@list@%+len
%define listIndex(name,i) __%+name%+@list@%+i

; name,index,data
%macro listsetindex 3
    %define __%[%1]@list@%[%2] %3
    %if %2>=listlen(%1)
        %assign __%[%1]@list@len %2+1
    %endif
%endmacro

; name,data
%macro listpush 2
    %assign %%index listlen(%1)
    listsetindex %1,%%index,%{2:-1}
%endmacro

;a,b,c,d

; name,index
%macro listrmsh 2
    %assign %%i %2
    %rep listlen(%1)-%%i-1
        listsetindex %1,%%i,listIndex(%1,%eval(%%i+1))
    %endrep
    %assign __%[%1]@list@len listlen(%1)-1
%endmacro

; name,index
%macro listrm 2
    %assign %%i %2
    listsetindex %1,%%i,listIndex(%1,%eval(listlen(%1)-1))
    %assign __%[%1]@list@len listlen(%1)-1
%endmacro

%macro listwarning 1
    %assign %%i 0
    %rep listlen(%1)
        %warning listIndex(%1,%%i)
        %assign %%i %%i+1
    %endrep
%endmacro

%macro listToTuple 1
    %assign %%i 1
    %xdefine %%tuple listIndex(%1,0)
    %rep listlen(%1)-1
        %xdefine %%tuple%+,%+listIndex(%1,%%i)
        %assign %%i %%i+1
    %endrep
    retm {%%tuple}
%endmacro

%macro listdelete 1
    %assign %%i 1
    %rep listlen(%1)
        %undef __%[%1]@list@%[%%i]
    %endrep
    %undef __%[%1]@list@len
%endmacro