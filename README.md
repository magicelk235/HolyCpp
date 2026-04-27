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
``````

## Usage

### Run the compiler

```bash
./hcpp <path>
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

## Syntax Examples

### Hello World

```nasm
include <io>

func main(@byte args)>1
    print("hello world\n")
    return 0
end
```

---

### Reading Input

```nasm
include <io>

func main(@byte args)>1
    new qword x
    x = scanf('i')
    return 0
end
```

Supported format specifiers: `'i'` integer, `'u'` unsigned integer, `'f'` float, `'c'` char, `'s'` string, `'b'` bool.

---

### Control Flow

```nasm
include <io>

func main(@byte args)>1
    new qword x
    x = scanf("i")
    if x>0
        printf("%i is bigger than 0\n",x)
        while x>0
            printf("%i\n",x)
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

## Library Examples

### Math (`<math>`)

```nasm
include <io>
include <math>

func main(@byte args)>1
    new float x = 0.5
    new float result

    result = sin(x)
    printf("sin(%f) = %f\n", x, result)

    result = sqrt(2.0)
    printf("sqrt(2) = %f\n", result)

    new qword r = rand(1, 100)
    printf("random 1-100: %i\n", r)

    return 0
end
```

Available: `sin`, `cos`, `tan`, `arcsin`, `arccos`, `arctan`, `sqrt`, `abs`, `fabs`, `floor`, `ceil`, `pow`, `log`, `ln`, `exp`, `rand`, `frand`, `toInt`, `toFloat`, `max`, `min`. Constants: `pi`, `e`.

---

### Strings (`<string>`)

```nasm
include <io>
include <string>

func main(@byte args)>1
    new byte buf[32]
    new qword num = 12345

    intToStr(num, @buf)
    printf("number as string: %s\n", @buf)

    new float f = 3.14159
    floatToStr(f, @buf)
    printf("float as string: %s\n", @buf)

    new byte input[] = "42"
    num = strToInt(@input)
    printf("string as number: %i\n", num)

    return 0
end
```

Available: `strToInt`, `intToStr`, `unsignedToStr`, `strToFloat`, `floatToStr`, `strToBool`, `boolToStr`, `sprintf`, `sscanf`.

---

### Arrays (`<arrays>`)

```nasm
include <io>
include <arrays>

func main(@byte args)>1
    new qword arr[10]
    new qword i

    fill(@arr, 0, 8)
    arr[0] = 42
    arr[5] = 99

    if contains(@arr, 99, 8)
        i = find(@arr, 99, 8)
        printf("found 99 at index %i\n", i)
    end

    new qword arr2[10]
    copy(@arr2, @arr)

    return 0
end
```

Available: `fill`, `find`, `contains`, `count`, `copy`, `equal`.

---

### File I/O (`<io>`)

```nasm
include <io>

func main(@byte args)>1
    new qword fd
    new byte buf[1024]

    fd = open("test.txt", "r")
    read(fd, @buf, -1)
    printf("file contents: %s\n", @buf)
    close(fd)

    fd = open("output.txt", "w")
    write(fd, "Hello from HolyCpp!\n", -1)
    close(fd)

    return 0
end
```

File modes: `"r"` read, `"w"` write (create/truncate), `"a"` append, `"r+"` read/write, `"w+"` read/write (create), `"a+"` read/append.

Available: `open`, `close`, `read`, `write`, `fstat`, `mmap`, `ioctl`, `print`, `printf`, `scan`, `scanf`, `exit`.

---

### Process (`<process>`)

```nasm
include <io>
include <process>

func main(@byte args)>1
    print("waiting 1.5 seconds...\n")
    sleep(1.5)

    new qword code = run("/bin/ls", "-l")
    printf("ls exited with code %i\n", code)

    return 0
end
```

Available: `sleep`, `run`, `wait`.

---

### Graphics (`<graphics>`)

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

---

### Terminal Colors (`<io>`)

```nasm
include <io>

func main(@byte args)>1
    printf("%FRed text!\n", 0xFF0000)
    printf("%FGreen text!\n", 0x00FF00)
    printf("%F%BWhite on blue!\n", 0xFFFFFF, 0x0000FF)

    print("\x1b[0m")
    return 0
end
```

Color format: `0xRRGGBB`. Use `%F` for foreground (text) color, `%B` for background color.