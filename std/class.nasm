; name,size,signed
%macro newType 2-3 0
    %assign __%1@class@size %2
    %assign __%1@class@signed %3
%endmacro

%macro class 1
    %push
    setBlockType "class"
    %xdefine %$className %1
    %define inClass 1
    newDict __%1@class@functions
    newDict __%1@class@reference
    newType %1,0
%endmacro

%define classSize(x) __%+ x %+@class@size
%define classSigned(x) __%+ x %+ @class@signed
%define classFunctions(x) __%+ x %+@class@functions
%define classReference(x) __%+ x @class@reference
%define classFunctionOffset(class,func) dictkey(classFunctions(class),func)
%define classReferencefOffset(class,ref) dictkey(classReference(class),ref)

;%macro newStatic

%macro endclass 0 

%endmacro