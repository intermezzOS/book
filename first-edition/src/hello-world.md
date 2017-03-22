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

By giving this line a label, we can call it, sort of like a function. That’s what
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

We saw `section` briefly, but I told you we’d get to it later. The place where
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

That’s it! We could theoretically stop here, but instead, let’s actually print
the “Hello world” text to the screen. We’ll start off with an ‘H’:

```x86asm
global start

section .text
bits 32
start:
    mov word [0xb8000], 0x0248 ; H
    hlt
```

This new line is the most complicated bit of assembly we’ve seen yet. There’s a
lot packed into this little line.

The first important bit is `mov`. This is short for `move`, and it sorta looks
like this:

```text
mov size place, thing
```

Oh, `;` starts a comment, remember? So the `; H` is just for us. I put this
comment here because this line prints an `H` to the screen!

Yup, it does. Okay, so here’s why: `mov` copies `thing` into `place`. The amount
of stuff it copies is determined by `size`.

```x86asm
;   size place      thing
;   |    |          |
;   V    V          V
mov word [0xb8000], 0x0248 ; H
```

“Copy one word: the number `0x0248` to ... some place.

The `place` looks like a number just like `0x0248`, but it has square 
brackets `[]` around it. Those brackets are special. They mean “the address 
in memory located by this number.” In other words, we’re copying the number 
`0x0248` into the specific memory location `0xb8000`. That’s what this line does.

Why? Well, we’re using the screen as a “memory mapped” device. Specific
positions in memory correspond to certain positions on the screen. And
the position `0xb8000` is one of those positions: the upper-left corner of the
screen.

> **By the way...**
>
> "Memory mapping" is one of the fundamental techniques used in computer
engineering to help the CPU know how to talk to all the different physical
components of a computer. The CPU itself is just a weird little machine that
moves numbers around. It's not of any use to humans on its own: it needs to be
connected to devices like RAM, hard drives, a monitor, and a keyboard. The way
the CPU does this is through a *bus*, which is a huge pipeline of wires
connecting the CPU to every single device that might have data the CPU needs.
There's one wire per bit (since a wire can store a 1 or a 0 at any given time).
A 32-bit bus is literally 32 wires in parallel that run from the CPU to a bunch
of devices like Christmas lights around a house.
>
> There are two buses that we really care about in a computer: the address bus
and the data bus. There's also a third signal that lets all the devices know
whether the CPU is requesting data from an input (reading, like from the
keyboard) or sending data to an output (writing, like to the monitor via the
video card). The address bus is for the CPU to send location information, and
the data bus is for the CPU to either write data to or read data from that
location.  Every device on the computer has a unique hard coded numerical
location, or "address", literally determined by how the thing is wired up at
the factory. In the case of an input/read operation, when it sends `0x1001A003`
out on the address bus and the control signal notifies every device that it's a
read operation, it's asking, "What is the data currently stored at location
`0x1001A003`?" If the keyboard happens to be identified by that particular
address, and the user is pressing SPACE at this time, the keyboard says, "Oh,
you're talking to me!" and sends back the ASCII code `0x00000020` (for "SPACE")
on the data bus.
>
> What this means is that memory on a computer isn't just representing things like
RAM and your hard drive. Actual human-scale devices like the keyboard and mouse
and video card have their own memory locations too. But instead of writing a byte
to a hard drive for storage, the CPU might write a byte representing some color
and symbol to the monitor for display. There's an industry standard somewhere
that says video memory must live in the address range beginning `0xb8000`. In
order for computers to be able to work out of the box, this means that the BIOS
needs to be manufactured to assume video lives at that location, and the
motherboard (which is where the bus is all wired up) has to be manufactured to
route a `0xb8000` request to the video card.  It's kind of amazing this stuff
works at all! Anyway, "memory mapped hardware", or "memory mapping" for short,
is the name of this technique.

Now, we are copying `0x0248`. Why this number? Well, it’s in three parts:

```text
 __ background color
/  __foreground color
| /
V V
0 2 48 <- letter, in ASCII
```

We’ll start at the right. First, two numbers are the letter, in ASCII. `H` is
72 in ASCII, and 48 is 72 in hexadecimal: `(4 * 16) + 8 = 72`. So this will
write `H`.

The other two numbers are colors. There are 16 colors available, each with a
number. Here’s the table:

```text
| Value | Color          |
|-------|----------------|
| 0x0   | black          |
| 0x1   | blue           |
| 0x2   | green          |
| 0x3   | cyan           |
| 0x4   | red            |
| 0x5   | magenta        |
| 0x6   | brown          |
| 0x7   | gray           |
| 0x8   | dark gray      |
| 0x9   | bright blue    |
| 0xA   | bright green   |
| 0xB   | bright cyan    |
| 0xC   | bright red     |
| 0xD   | bright magenta |
| 0xE   | yellow         |
| 0xF   | white          |
```

So, `02` is a black background with a green foreground. Classic. Feel free to
change this up, use whatever combination of colors you want!

So this gives us a `H` in green, over black. Next letter: `e`.

```x86asm
global start

section .text
bits 32
start:
    mov word [0xb8000], 0x0248 ; H
    mov word [0xb8002], 0x0265 ; e
    hlt
```

Lower case `e` is `65` in ASCII, at least, in hexadecimal. And `02` is our same
color code. But you’ll notice that the memory location is different.

Okay, so we copied four hexadecimal digits into memory, right? For our `H`.
`0248`. A hexadecimal digit has sixteen values, which is 4 bits (for example, `0xf`
would be represented in bits as `1111`). Two of them make 8 bits, i.e. one byte.
Since we need half a word for the colors (`02`), and half a word for the `H` (`48`),
that’s one word in total (or two bytes). Each place that the memory address points
to can hold one byte (a.k.a. 8 bits or half a word). Hence, if our first memory
position is at `0`, the second letter will start at `2`.

>You might be wondering, "If we're in 32 bit mode, isn't a word 32 bits?" since sometimes ‘word’ is used to talk about native CPU register size. Well, the ‘word’ keyword in the context of x86\_64 assembly specifically refers to 2 bytes, or 16 bits of data.  This is for reasons of backwards compatibility.


This math gets easier the more often you do it. And we won’t be doing _that_ much
more of it. There is a lot of working with hex numbers in operating systems work,
so you’ll get better as we practice.

With this, you should be able to get the rest of Hello, World. Go ahead and try
if you want: each letter needs to bump the location twice, and you need to look
up the letter’s number in hex.

If you don’t want to bother with all that, here’s the final code:

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

Okay! So we have two different `.o` files: `multiboot_header.o` and `boot.o`.
But what we need is _one_ file with both of them. Our OS doesn’t have the
ability to do anything yet, let alone load itself in two parts somehow. We just
want one big binary file.

Enter ‘linking’. If you haven’t worked in a compiled language before, you
probably haven’t had to deal with linking before. Linking is how we’ll turn
these two files into a single output: by linking them together.

Open up a file called `linker.ld`and put this in it:

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

This is a ‘linker script’. It controls how our linker will combine these
files into the final output. Let’s take it bit-by-bit:

```text
ENTRY(start)
```

This sets the ‘entry point’ for this executable. In our case, we called our
entry point by the name people use: `start`. Remember? In `boot.asm`? Same
name here.

```text
SECTIONS {
```

Okay! I’ve been promising you that we’d talk about sections. Everything inside
of these curly braces is a section. We annotated parts of our code with
sections earlier, and here, in this part of the linker script, we will describe
each section by name and where it goes in the resulting output.

```text
    . = 1M;
```

This line means that we will start putting sections at the one megabyte mark.
This is the conventional place to put a kernel, at least to start. Below one
megabyte is all kinds of memory-mapped stuff. Remember the VGA stuff? It
wouldn’t work if we mapped our kernel’s code to that part of memory... garbage
on the screen!

```text
    .boot :
```

This will create a section named `boot`. And inside of it...

```text
        *(.multiboot_header)
```

... goes every section named `multiboot_header`. Remember how we defined that
section in `multiboot_header.asm`? It’ll be here, at the start of the `boot`
section. That’s what we need for GRUB to see it.

```text
    .text :
```

Next, we define a `text` section. The `text` section is where you put code.
And inside of it...

```text
        *(.text)
```

... goes every section named `.text`. See how this is working? The syntax is a
bit weird, but it’s not too bad.

That’s it for our script! We can then use `ld` to link all of this stuff
together:

```bash
$ ld --nmagic --output=kernel.bin --script=linker.ld multiboot_header.o boot.o
```

Recall that on Mac OS X you will want to use the linker we installed to
`~/opt` and not your system linker. For example, if you did not change any of
the defaults in the installation script, this linker will be located at
`$HOME/opt/bin/x86_64-pc-elf-ld`.

By running this command, we do a few things:

```text
--nmagic
```

TODO: https://github.com/intermezzOS/book/issues/30

```text
--output=kernel.bin
```

This sets the name of our output file. In our case, that’s `kernel.bin`. We’ll be using
this file in the next step. It’s our whole kernel!

```text
--script=linker.ld
```

This is the linker script we just made.

```text
multiboot_header.o boot.o
```

Finally, we pass all the `.o` files we want to link together.

That’s it! We’ve now got our kernel in the `kernel.bin` file. Next, we’re going to
make an ISO out of it, so that we can load it up in QEMU.
