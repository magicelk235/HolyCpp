# HolyC++

HolyC++ is a compiled programming language that targets **x86-64 Linux**. It compiles down to native x86-64 machine code via Nasm.

## Installation

### Requirements

- x86-64 Linux
- `nasm` — the assembler
- `ld` — the linker

```bash
# Debian/Ubuntu
sudo apt install nasm binutils

# Arch
sudo pacman -S nasm binutils

# Fedora
sudo dnf install nasm binutils
```

### Download the compiler

Clone the repo:

```bash
git clone https://github.com/magicelk235/HolyCpp.git
cd HolyCpp
```

## Usage

### Run the compiler

```bash
./hcpp <path>
```

### Writing a program

Create a `.hcpp` file. Every program has a `main` function as its entry point:

```nasm
%include "lib/lib.nasm"

func main(@byte args)>1
    new const byte msg[] = "Hello, World!\n"
    call print(@msg)
    return 0
end
```

The `%include "lib/lib.nasm"` line brings in the full standard library.

---

## Language Reference

### Variables

```nasm
new qword x = 42           ; local integer
new qword y                ; local, uninitialized
new global qword counter   ; global (BSS)
new const byte msg[] = "hello\n"   ; constant string
new qword arr[10]          ; array of 10 qwords
new byte buf[1024]         ; byte buffer
```

### Assignment and expressions

```nasm
set x = (a + b) * c         ; evaluate expression and assign
set y = a == b              ; y = 1 if equal, 0 otherwise
set ptr = @myVar            ; ptr = address of myVar
```


### Functions

```nasm
; declare a function with 2 args and 1 return value
func add(qword a, qword b)>1
    new qword result
    set result = a+b
    return result
end

; call it
new qword sum
set sum = add(10, 20)
```

The `.` prefix on a type marks it as a float argument:

```nasm
func square(.qword x)>1
    return x**2
end
```

### Control flow

```nasm
if x == 0
    ; ...
elif x < 0
    ; ...
else
    ; ...
end

while x < 10
    set x = x+1
end

dowhile x < 10
    set x = x+1
end
```

Use `break` to exit a loop and `continue` to skip to the next iteration.

### Arrays

```nasm
new qword arr[10]
set arr[0] = 42           ; write element
set x = arr[2]            ; read element
set x = arr[#]            ; read byte length
```

Array memory layout: `[8-byte byte length][element0][element1]...`

List literals use `,` as a separator: `[1,2,3,4]`

---

## Examples

### Hello World

Print a string to stdout.

```nasm
%include "lib/arrays.nasm"
%include "lib/string.nasm"
%include "lib/io.nasm"

func main(@byte args)>1
    call print("hello world\n")
    return 0
end
```

---

### Reading Input

Read an integer from stdin with `scanf`.

```nasm
%include "lib/arrays.nasm"
%include "lib/string.nasm"
%include "lib/io.nasm"

func main(@byte args)>1
    new qword x
    set x = scanf("i")
    return 0
end
```

Supported format specifiers: `"i"` integer, `"f"` float, `"c"` char, `"s"` string, `"b"` bool.

---

### Control Flow

`if`/`else` and a `while` countdown loop.

```nasm
%include "lib/arrays.nasm"
%include "lib/string.nasm"
%include "lib/io.nasm"

func main(@byte args)>1
    new qword x
    set x = scanf("i")
    if x>0
        call printf("%i is bigger than 0\n",x)
        while x>0
            call printf("%i\n,x)
            set x = x-1
        end
    else
        call printf("%i is smaller than 0\n",x)
    end
    return 0
end
```

---

### Functions

Declare a function with multiple arguments and a return value.

```nasm
%include "lib/arrays.nasm"
%include "lib/string.nasm"
%include "lib/io.nasm"

func sum(qword x,qword y)>1
    call printf("calculating %i+%i\n", x, y)
    call printf("the arg count is %i\n", argc)
    return x+y
end

func main(@byte args)>1
    call sum(2,4)
    return 0
end
```

The `>1` suffix declares the number of return values. Arguments are separated by `,`.

---

### Floating Point

Prefix a type with `.` to treat it as a float. Here, pi is multiplied by a user-supplied float.

```nasm
%include "lib/arrays.nasm"
%include "lib/string.nasm"
%include "lib/io.nasm"

func main(@byte args)>1
    new qword x = 3.1415926535
    set x = x * scanf("f")
    call printf("The result is %f\n", x)
    return 0
end
```

---

### Arrays

Declare a fixed-size array, fill it element by element, and print each value.

```nasm
%include "lib/arrays.nasm"
%include "lib/string.nasm"
%include "lib/io.nasm"

func main(@byte args)>1
    new qword x = 0
    new qword arr[10]
    while x < arr[#]/8
        set arr[x] = scanf("i")
        call printf("arr[%i] = %i\n", x, arr[x])
        set x = x+1
    end
    return 0
end
```

`arr[#]` returns the byte length of the array; dividing by the element size gives the element count.

---

### Image (Framebuffer)

Open a BMP file and draw it directly to the Linux framebuffer.

```nasm
%include "lib/arrays.nasm"
%include "lib/string.nasm"
%include "lib/io.nasm"
%include "lib/graphics.nasm"

func main(@byte args)>1
    new qword @image
    new qword fb[3]

    set fb = openfb()
    set @image = openbmp("image.bmp")
    call drawbmp(@fb, @image, 1, 1)

    return 0
end
```