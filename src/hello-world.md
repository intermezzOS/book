# Hello, world!

Now that we’ve got the headers out of the way, let’s do the traditional first
program: Hello, world!

## The smallest kernel

Our hello world will be just _20_ lines of assembly code. Let’s begin.
Open a file called `boot.asm` and put this in it:

```x86asm
start:
    hlt
```

You’ve seen the `name:` form before: it’s a _label_. This lets us name a line
of code. We’ll call this label `start`, which is the traditional name.
GRUB will use this convention to know where to begin.

The `hlt` statement is our first bit of ‘real’ assembly. So far, we had just
been declaring data. This is actual, executable code. It’s short for ‘halt’.
In other words, it ends the program.

By giving this line a label, we can call it, like a function. That’s what
GRUB does: “Call the function named `start`.” This function has just one
line: stop.

Unlike many other languages, you’ll notice that there’s no way to say if
this ‘function’ takes any arguments or not. We’ll talk more about that later.

This code won’t quite work on its own though. We need to do a little bit more
bookkeeping first. Here’s the next few lines:

```x86asm
global start

section .text
bits 32
start:
    hlt
```

Three new bits of information. The first:

```x86asm
global start
```

This says “I’m going to define a label `start`, and I want it to be available
outside of this file.” If we don’t say this, GRUB won’t know where to find its
definition. You can kind of think of it like a ‘public’ annotation in other
languages.

```x86asm
section .text
```

We saw `section` breifly, but I told you we’d get to it later. The place where
we get to it is at the end of this chapter. For the moment, all you need to
know is this: code goes into a section named `.text`. Everything that comes
after the `section` line is in that section, until another `section` line.

```x86asm
bits 32
```

GRUB will boot us into protected mode, aka 32-bit mode. So we have to specify
that directly. Our Hello World will only be in 32 bits. We’ll transition from
32-bit mode to 64-bit mode in the next chapter, but it’s a bit involved.
So let’s just stay in protected mode for now.

That’s it! We could theoretically stop here, but instead, let’s actually
print the “Hello world” text to the screen. We’ll start off with an ‘H’:

```x86asm
global start

section .text
bits 32
start:
    mov word [0xb8000], 0x0248 ; H
    hlt
```

This new line is the most complicated bit of assembly we’ve seen yet.
There’s a lot packed into this little line.

EXPLANATION GOES HERE

```x86asm
global start

section .text
bits 32
start:
    mov word [0xb8000], 0x0248 ; H
    mov word [0xb8002], 0x0265 ; e
    mov word [0xb8004], 0x026c ; l
    mov word [0xb8006], 0x026c ; l
    mov word [0xb8008], 0x026f ; o
    mov word [0xb800a], 0x022c ; ,
    mov word [0xb800c], 0x0220 ; 
    mov word [0xb800e], 0x0277 ; w
    mov word [0xb8010], 0x026f ; o
    mov word [0xb8012], 0x0272 ; r
    mov word [0xb8014], 0x026c ; l
    mov word [0xb8016], 0x0264 ; d
    mov word [0xb8018], 0x0221 ; !
    hlt
```

Finally, now that we’ve got all of the code working, we can assemble our
`boot.asm` file with `nasm`, just like we did with the `multiboot_header.asm`
file:

```bash
$ nasm -f elf64 boot.asm
```

This will produce a `boot.o` file. We’re almost ready to go!

## Linking it together

EXPLAIN ALL THIS

```text
ENTRY(start)

SECTIONS {
    . = 1M;

    .boot :
    {
        /* ensure that the multiboot header is at the beginning */
        *(.multiboot_header)
    }

    .text :
    {
        *(.text)
    }
}
```

```bash
$ ld -n -o kernel.bin -T linker.ld multiboot_header.o boot.o
```
