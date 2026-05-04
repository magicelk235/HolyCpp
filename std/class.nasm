%assign __int8@class@size 1
%assign __int16@class@size 2
%assign __int32@class@size 4
%assign __int64@class@size 8

%assign __int8@class@signed 1
%assign __int16@class@signed 1
%assign __int32@class@signed 1
%assign __int64@class@signed 1
%assign __int@class@signed 1

%assign __uint8@class@size 1
%assign __uint16@class@size 2
%assign __uint32@class@size 4
%assign __uint64@class@size 8

%assign __int@class@size 4
%assign __uint@class@size 4
%assign __float@class@size 64
%assign __float@class@signed 1
%assign __char@class@size 1
%assign __bool@class@size 1
%assign __short@class@size 2
%assign __long@class@size 8


%macro class 1
    %push
    setBlockType "class"
    %xdefine %$className %1
    %define inClass 1
    newDict __%1@class@functions
    newDict __%1@class@reference
    %assign __%1@class@size
%endmacro

%define classSize(x) __%+ x %+@class@size
%define classSigned(x) __%+ x %+ @class@signed
%define classFunctions(x) __%+ x %+@class@functions
%define classReference(x) __%+ x @class@reference
%define classFunctionOffset(class,func) dictkey(classFunctions(class),func)
%define classReferencefOffset(class,ref) dictkey(classReference(class),ref)

%macro newStatic

%macro endclass 0 

%endmacro