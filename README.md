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

Assemble and link it

``````bash
nasm -f elf64 hcpp.nasm
ld -o hcpp hcpp.o
# optional for cli
nasm -f elf64 cli.nasm
ld -o cli cli.o
``````

## Usage

### Run the compiler

```bash
# direct
./hcpp <path>
# cli
./cli
```

### Writing a program

Create a `.hcpp` file. Every program has a `main` function as its entry point:

```nasm
include <io>

func main(@byte args)>1
    print("Hello, World!\n")
    return 0
end
```

## Language Reference

### Variables

```nasm
new qword x = 42           ; local/global integer
new qword y                ; local/global uninitialized
new global qword counter   ; global (BSS)
new const byte msg[] = "hello\n"   ; constant string
new qword arr[10]          ; array of 10 qwords
new byte buf[1024]         ; byte buffer
new float e = 2.7182818285 ; local/global float64
new ~qword count = 1123456 ; local/global unsigned qword
```
Use `int`,`long`,`char`,`short`,`bool` instead of sizes for builtin types
### Assignment and expressions

```nasm
x = (a + b) * c         ; evaluate expression and assign
y = a == b              ; y = 1 if equal, 0 otherwise
ptr = @myVar            ; ptr = address of myVar
```

### Functions

```nasm
; declare a function with 2 args and 1 return value
func add(qword a, qword b)>1
    new qword result
    result = a+b
    return result
end

; call it
new qword sum
sum = add(10, 20)
```

The float prefix replaces the size to make a float argument:

```nasm
func square(float x)>1
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

loop 15
    ; ...
end

for x = 5,x>0,x--
    ; ...
end

while x < 10
    x++
end

dowhile x < 10
    x++
end
```

Use `break` to exit a loop and `continue` to skip to the next iteration.

### Arrays

```nasm
new qword arr[10]
arr[0] = 42           ; write element
x = arr[2]            ; read element
x = arr[#]            ; read byte length
```

Array memory layout: `[8-byte byte length][element0][element1]...`

List literals use `,` as a separator: `[1,2,3,4]`

---

## Examples

### Hello World

Print a string to stdout.

```nasm
include <io>

func main(@byte args)>1
    print("hello world\n")
    return 0
end
```

---

### Reading Input

Read an integer from stdin with `scanf`.

```nasm
include <io>

func main(@byte args)>1
    new qword x
    x = scanf('i')
    return 0
end
```

Supported format specifiers: `'i'` integer,`'u'` unsigned integer, `'f'` float, `'c'` char, `'s'` string, `'b'` bool.

---

### Control Flow

`if`/`else` and `while`/`for`/`loop`.

```nasm
include <io>

func main(@byte args)>1
    new qword x
    x = scanf("i")
    if x>0
        printf("%i is bigger than 0\n",x)
        while x>0
            printf("%i\n,x)
            x--
        end
    else
        printf("%i is smaller than 0\n",x)
    end
    return 0
end
```

---

### Functions

Declare a function with multiple arguments and a return value.

```nasm
include <io>

func sum(qword x,qword y)>1
    printf("calculating %i+%i\n", x, y)
    printf("the arg count is %i\n", argc)
    return x+y
end

func main(@byte args)>1
    sum(2,4)
    return 0
end
```

The `>1` suffix declares the number of return values. Arguments are separated by `,`.

---

### Floating Point

Prefix a type with float instead of size. Here, pi is multiplied by a user-supplied float.

```nasm
include <io>

func main(@byte args)>1
    new float x = 3.1415926535
    x *= scanf("f")
    printf("The result is %f\n", x)
    return 0
end
```

---

### Arrays

Declare a fixed-size array, fill it element by element, and print each value.

```nasm
include <io>

func main(@byte args)>1
    new qword x = 0
    new qword arr[10]
    for x=0,x < arr[#]/8,x++
        arr[x] = scanf("i")
        printf("arr[%i] = %i\n", x, arr[x])
    end
    return 0
end
```

`arr[#]` returns the byte length of the array; dividing by the element size gives the element count.

---

### Image (Framebuffer)

Open a BMP file and draw it directly to the Linux framebuffer.

```nasm
include <graphics>

func main(@byte args)>1
    new qword @image

    openfb()
    @image = openbmp("image.bmp")
    drawbmp(@image, 1, 1)
    blit()

    return 0
end
```
