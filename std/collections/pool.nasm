; name,data
%macro newPool 1-*
    %assign __%[%1]@pool@len %0-1
    %if %0>1
        poolset %1,%{2:-1}
    %endif
%endmacro

; name,data
%macro poolset 1-*
    %xdefine %%name %1
    %rep %0-1
        %rotate 1
        pooladd %%name,%1
    %endrep
%endmacro

%define poollen(name) __%+name%+@pool@%+len
%define poolin(name,item) %isidn(__%+name%+@pool@%+item,1)

; name,item
%macro pooladd 2
    %if !poolin(%1,%2)
        %define __%[%1]@pool@%[%2] 1
        %assign __%[%1]@pool@len poollen(%1)+1
    %endif
%endmacro

; name,item
%macro poolrm 2
    %if poolin(%1,%2)
        %define __%[%1]@pool@%[%2] 0
        %assign __%[%1]@pool@len poollen(%1)-1
    %endif
%endmacro