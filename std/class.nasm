; name,size,signed
%macro newType 2-3 0
    %xdefine __macroName %1
    %assign __class@size@%[__macroName] %2
    %assign __class@signed@%[__macroName] %3
    %unimacro %[__macroName] 1-*
    %unmacro %[__macroName] 1-*
    %macro %[__macroName] 1-*
        new %?,%{1:-1}
    %endmacro
%endmacro

%assign inClass 0

%macro class 1
    %assign inClass 1
    %push
    setBlockType "class"
    newType %1,0
    %xdefine %$className %1
    %define inClass 1
    newDict __class@functions@%[%$className]
    newDict __class@reference@%[%$className]
    newDict __class@static@%[%$className]
%endmacro

%define classSize(x) merge(__class@size@, x)
%define classSigned(x) merge(__class@signed@, x)
%define classFunctions(x) merge(__class@functions@, x)
%define classReference(x) merge(__class@reference@, x)
%define classStatic(x) merge(__class@static@, x)
%define classFunctionOffset(class,func) dictkey(classFunctions(class),func)
%define classReferenceOffset(class,ref) dictkey(classReference(class),ref)
%define classStaticAddr(class,ref) dictkey(classStatic(class),ref)

; allocclass(name, type, depth, shape, data) - instance variable
%macro allocclass 5
    %xdefine %?prefixedName %[%$className]@%[%1]

    listToTuple %4
    newRef %?prefixedName,0,%2,%3,__1

    dictsetkey __class@reference@%[%$className],%1,classSize(%$className)
    %assign __class@size@%[__macroName] classSize(%$className)+totalSize(%?prefixedName)
%endmacro

; allocstatic(name, type, depth, shape, data) - static variable (global + add to class dict)
%macro allocstatic 5
    %xdefine %?prefixedName %[%$className]@%[%1]

    listToTuple %4
    newRef %?prefixedName,0,%2,%3,__1

    allocbss totalSize(%?prefixedName)
    %xdefine __ref@addr@%[%?prefixedName] __1
    dictsetkey __class@static@%[%$className],%1,__1
%endmacro

%macro endclass 0
    %assign inClass 0
%endmacro