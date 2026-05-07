; name,size,signed
%macro newType 2-3 0
    %xdefine __macroName type@%[%1]
    %assign __%[__macroName]@class@size %2
    %assign __%[__macroName]@class@signed %3
    %xdefine __typeName %1
    %macro %[__macroName] 1-*
        new %?,%{1:-1}
    %endmacro
    %xdefine %1 __macroName
%endmacro

%assign inClass 0

%macro class 1
    %assign inClass 1
    %push
    setBlockType "class"
    newType %1,0
    %xdefine %$className %1
    %define inClass 1
    newDict __%[%$className]@class@functions
    newDict __%[%$className]@class@reference
%endmacro

%define classSize(x) __%+ x %+@class@size
%define classSigned(x) __%+ x %+ @class@signed
%define classFunctions(x) __%+ x %+@class@functions
%define classReference(x) __%+ x @class@reference
%define classFunctionOffset(class,func) dictkey(classFunctions(class),func)
%define classReferencefOffset(class,ref) dictkey(classReference(class),ref)

; size, name
%macro allocclass 2
    dictsetkey __%[%$className]@class@reference,%2,classSize(%$className)
    %assign __%[__macroName]@class@size classSize(%$className)+%1
%endmacro

%macro endclass 0 
    %assign inClass 0
%endmacro