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
    newDict __%[%$className]@class@static
%endmacro

%define classSize(x) __%+ x %+@class@size
%define classSigned(x) __%+ x %+ @class@signed
%define classFunctions(x) __%+ x %+@class@functions
%define classReference(x) __%+ x %+@class@reference
%define classStatic(x) __%+ x %+@class@static
%define classFunctionOffset(class,func) dictkey(classFunctions(class),func)
%define classReferenceOffset(class,ref) dictkey(classReference(class),ref)
%define classStaticAddr(class,ref) dictkey(classStatic(class),ref)

; allocclass(name, type, depth, shape, data) - instance variable
%macro allocclass 5
    %xdefine %?prefixedName %[%$className]@%[%1]

    listToTuple %4
    newRef %?prefixedName,0,%2,%3,__1

    dictsetkey __%[%$className]@class@reference,%1,classSize(%$className)
    %assign __%[__macroName]@class@size classSize(%$className)+totalSize(%?prefixedName)
%endmacro

; allocstatic(name, type, depth, shape, data) - static variable (global + add to class dict)
%macro allocstatic 5
    %xdefine %?prefixedName %[%$className]@%[%1]

    listToTuple %4
    newRef %?prefixedName,0,%2,%3,__1

    allocbss totalSize(%?prefixedName)
    %xdefine __%[%?prefixedName]@ref@addr __1
    dictsetkey __%[%$className]@class@static,%1,__1
%endmacro

%macro endclass 0
    %assign inClass 0
%endmacro