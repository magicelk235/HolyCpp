%macro warningretm 0
    %assign %%i 1
    %rep __0
        %warning __%[%%i]
        %assign %%i %%i+1
    %endrep
%endmacro