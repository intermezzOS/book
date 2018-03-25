# Multiboot headers

Let’s get going! The very first thing we’re going to do is create a ‘multiboot
header’. What’s that, you ask? Well, to explain it, let’s take a small step
back and talk about how a computer boots up.

One of the amazing and terrible things about the x86 architecture is that it’s
maintained backwards compatibility throughout the years. This has been a
competitive advantage, but it’s also meant that the boot process is largely a
pile of hacks. Each time a new iteration comes out, a new step gets added to
the process. That’s right, when your fancy new computer starts up, it thinks
it’s an 8086 from 1976. And then, through a succession of steps, we transition
through more and more modern architectures until we end at the latest and
greatest.

The first mode is called ‘real mode’. This is a 16 bit mode that the original
x86 chips used. The second is ‘protected mode’. This 32 bit mode adds new
things on top of real mode. It’s called ‘protected’ because real mode sort of
let you do whatever you wanted, even if it was a bad idea. Protected mode was
the first time that the hardware enabled certain kinds of protections that allow
us to exercise more control around such things as RAM. We’ll talk more about
those details later.

The final mode is called ‘long mode’, and it’s 64 bits.

> **By the way...**
>
> Well, that’s actually a lie: there’s two. Initially, you’re not in long mode,
> you’re in ‘compatibility mode’. You see, when the industry was undergoing the
> transition from 32 to 64 bits, there were two options: the first was Intel’s
> Itanium 64-bit architecture. It did away with all of the stuff I just told
> you about. But that meant that programs had to be completely recompiled from
> scratch for the new chips. Intel’s big competitor, AMD, saw an opportunity
> here, and released a new set of chips called amd64. These chips were backwards
> compatible, and so you could run both 32 and 64 bit programs on them.
> Itanium wasn’t compelling enough to make the pain worth it, and so Intel released
> new chips that were compatible with amd64. The resulting architecture was then
> called x86\_64, the one we’re using today. The moral of the story? Intel tried
> to save you from all of the stuff we’re about to do, but they failed. So
> we have to do it.

So that’s the task ahead of us: make the jump up the ladder and get to
long mode. We can do it! Let’s talk more details.

## Firmware and the BIOS

So let's begin by turning the power to our computer on.

When we press the power button, electricity starts running, and a special piece of
software, known as the BIOS in Intel land, automatically runs.

With the BIOS we're already in the land of software, but unlike software that
you may be used to writing, the BIOS comes bundled with its computer and is located in
*r*ead-*o*nly *m*emory (ROM). While changing or updating stuff in ROM
is possible, it's not something you can do by invoking your favorite
package manager or by downloading something from some website. In fact some ROM
is literally hardwired into the computer and cannot be changed without
physically swapping it out. This makes sense here. The BIOS and the
computer are lifetime partners. Their existence doesn't make much sense without
each other.

One of the first things the BIOS does is run a ‘POST’ or *p*ower-*o*n *s*elf-*t*est
which checks for the availability and integrity of all the pieces of hardware that
the computer needs including the BIOS itself, CPU registers, RAM, etc. If you've
ever heard a computer beeping at you as it boots up, that's the POST reporting
its findings.

Assuming no problems are found, the BIOS starts the real booting process.

> **By the way...**
>
>For a while now most commercial computer manufacturers have hidden their BIOS
>booting process behind some sort of splash screen. It's usually possible to see the
>BIOS' logs by pressing some collection of keys when your computer is starting up.
>
>The BIOS also has a menu where you can see information about the computer
>like CPU and memory specs and all the hardware the BIOS detected like hard drives
>and CD and DVD drives. Typically this menu is accessed by pressing some other
>weird collection of keyboard keys while the computer is attempting to boot.

The BIOS automatically finds a ‘bootable drive’ by looking in certain
pre-determined places like the computer's hard drive and CD and DVD drives.
A drive is ‘bootable’ if it contains software that can finish the booting
process. In the BIOS menu you can usually change in what order the BIOS looks
for bootable drives or tell it to boot from a specific drive.

The BIOS knows it's found a bootable drive by looking at the first few kilobytes
of the drive and looking for some magical numbers set in that drive's
memory. This won't be the last time some magical numbers or hacky sounding things
are used on our way to building an OS. Such is life at such a low level...

When the BIOS has found its bootable drive, it loads part of the drive into
memory and transfers execution to it. With this process, we move away from what
comes dictated by the computer manufacturer and move ever closer to getting our
OS running.

## Bootloaders

The part of our bootable drive that gets executed is called a ‘bootloader’,
since it loads things at boot time. The bootloader’s job is to take our kernel,
put it into memory, and then transition control to it.

Some people start their operating systems journey by writing a bootloader. We
will not be doing that. Frankly, this whole startup process is more of an
exercise in reading manuals and understanding the history of esoteric hardware
than it is anything else. That stuff may interest you, and maybe someday we’ll
come back and write a bootloader of our own.

In the interest of actually getting around to implementing a kernel, instead, we’ll
use an existing bootloader: GRUB.

## GRUB and Multiboot

GRUB stands for ‘*gr*and *u*nified *b*ootloader’, and it’s a common one for
GNU/Linux systems. GRUB implements a specification called Multiboot, which is a
set of conventions for how a kernel should get loaded into memory. By following
the Multiboot specification, we can let GRUB load our kernel.

The way that we do this is through a ‘header’. We’ll put some information in a
format that multiboot specifies right at the start of our kernel. GRUB will
read this information, and follow it to do the right thing.

One other advantage of using GRUB: it will handle the transition from real mode
to protected mode for us, skipping the first step. We don’t even need to know
anything about all of that old stuff. If you’re curious about the kinds of
things you would have needed to know, put “A20 line” into your favorite search
engine, and get ready to cry yourself to sleep.

## Writing our own Multiboot header

I said we were gonna get to the code, and then I went on about more history.
Sorry about that! It’s code time for real! Inside your project directory, make
a new file called `multiboot_header.asm`, and open it in your favorite editor.
I use `vim`, but you should feel free to use anything you’d like.

```bash
$ touch multiboot_header.asm
$ vim multiboot_header.asm
```

Two notes about this: first of all, we’re just making this source file in the
top level. Don’t worry, we’ll clean house later. Remember: we’re going to build
stuff, and _then_ abstract it afterwards. It’s easier to start with a mess and
clean it up than it is to try to get it perfect on the first try.

Second, this is a `.asm` file, which is short for ‘assembly’. That’s right, we’re
going to write some assembly code here. Don’t worry! It’s not super hard.

### An aside about assembly

Have you ever watched Rich Hickey’s talk “Simple vs. Easy”? It’s a wonderful talk.
In it, he draws a distinction between these two words, which are commonly used as
synonyms.

TODO https://github.com/intermezzOS/book/issues/27

Assembly coding is simple, but that doesn’t mean that it’s easy. We’ll be doing
a little bit of assembly programming to build our operating system, but we
don’t need to know _that much_. It is completely learnable, even for someone
coming from a high-level language. You might need to practice a bit, and take
it slow, but I believe in you. You’ve got this.

### The Magic Number

Our first assembly file will be almost entirely _data_, not code. Here’s the
first line:

```x86asm
dd 0xe85250d6 ; magic number
```

Ugh! Gibberish! Let’s start with the semicolon (`;`). It’s a comment, that
lasts until the end of the line. This particular comment says ‘magic number’.
As we said, you’ll be seeing a lot of magic numbers in your operating system work.
The idea of a magic number is that it’s completely and utterly arbitrary. It
doesn’t mean anything. It’s just magic. The very first thing that the multiboot
specification requires is that we have the magic number `0xe85250d6` right
at the start.

> **By the way...**
>
> Wondering how a number can have letters inside of it? `0xe85250d6` is written in
hexadecimal notation. Hexadecimal is an example of a "numeral system" which is a
fancy term for a system for conveying numbers. The numeral system you're probably most
familiar with is the decimal system which conveys numbers using a combination of the
symbols `0` - `9`. Hexadecimal on the other hand uses a combination of 16 symbols:
`0` - `9` and `a` - `f`. Along with its fellow numeral system, binary, hexadecimal
is used *a lot* in low level programming. In order to tell if a number is written
in hexadecimal, you may be tempted to look for the use of letters in the number,
but a more surefire way is to look for a leading `0x`. While `100` isn't a hexadecimal
number, `0x100` is. To learn more about hexadecimal and binary [check this
out](appendix/numeral-systems.html).

What’s the value in having an arbitrary number there? Well, it’s a kind of safeguard
against bad things happening. This is one of the ways in which we can check that
we actually have a real multiboot header. If it doesn’t have the magic number,
something has gone wrong, and we can throw an error.

I have no idea why it’s `0xe85250d6`, and I don’t need to care. It just is.

Finally, the `dd`. It’s short for ‘define double word’. It declares that we’re
going to stick some 32-bit data at this location. Remember, when x86 first started,
it was a 16-bit architecture set. That meant that the amount of data that could be
held in a CPU register (or one ‘word’ as it's commonly known) was 16 bits.
To transition to a 32-bit architecture without losing backwards compatibility,
x86 got the concept of a ‘double word’ or double 16 bits.

### The mode code

Okay, time to add a second line:

```x86asm
dd 0xe85250d6 ; magic number
dd 0          ; protected mode code
```

This is another form of magic number. We want to boot into protected mode, and
so we put a zero here, using `dd` again. If we wanted GRUB to do something
else, we could look up another code, but this is the one that we want.

### Header length

The next thing that’s required is a header length. We could use `dd` and count
out exactly how many bytes that our header is, but there’s two reasons why
we’re not doing that:

1) Computers should do math, not people.
2) We’re going to add more stuff, and we’d have to recalculate this number each
   time. Or wait until the end and come back. See #1.

Here’s what this looks like:

```x86asm
header_start:
    dd 0xe85250d6                ; magic number
    dd 0                         ; protected mode code
    dd header_end - header_start ; header length
header_end:
```

You don’t have to align the comments if you don’t want to. I usually don’t, but
it looks nice and after we’re done with this file, we’re not going to mess with
it again, so we won’t be constantly re-aligning them in the future.

The `header_start:` and `header_end:` things are called ‘labels’. Labels let
us use a name to refer to a particular part of our code. Labels also refer to the
memory occupied by the data and code which directly follows it. So in our code above
the label `header_start` points directly to the memory at the very beginning of our
magic number and thus to the very beginning of our header.

Our third `dd` line uses those two labels to do some math: the header length is
the value of `header_end` minus the value of `header_start`. Because `header_start`
and `header_end` are just the addresses of places in memory, we can simply subtract
to get the distance between those two addresses. When we compile this assembly
code, the assembler will do this calculation for us. No need to figure out
how many bytes there are by hand. Awesome.

You’ll also notice that I indented the `dd` statements. Usually, labels go in
the first column, and you indent actual instructions. How much you indent is up
to you; it’s a pretty flexible format.

### The Checksum

The fourth field multiboot requires is a ‘checksum’. The idea is that we sum up
some numbers, and then use that number to check that they’re all what we
expected things to be. It’s similar to a hash, in this sense: it lets us and GRUB
double-check that everything is accurate.

Here’s the checksum:

```x86asm
header_start:
    dd 0xe85250d6                ; magic number
    dd 0                         ; protected mode code
    dd header_end - header_start ; header length

    ; checksum
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))
header_end:
```

Again, we’ll use math to let the computer calculate the sum for us. We add up
the magic number, the mode code, and the header length, and then subtract it
from a big number. `dd` then puts that value into this spot in our file.

> **By the way...**
>
> You might wonder why we're subtracting these values from 0x100000000. To answer this we can look at what [the multiboot spec](http://nongnu.askapache.com/grub/phcoder/multiboot.pdf) says about the checksum value in the header:
>
> > The field `checksum` is a 32-bit [unsigned value](http://intermezzos.github.io/book/appendix/signed-and-unsigned.html) which, when added to the other magic fields (i.e. `magic`, `architecture` and `header_length`), must have a 32-bit unsigned sum of zero.
>
> In other words:
>
> `checksum` + `magic_number` + `architecture` + `header_length` = 0
>
> We could try and "solve for" `checksum` like so:
>
> `checksum` =  -(`magic_number` + `architecture` + `header_length`)
>
> But here's where it gets weird. Computers don't have an innate concept of negative numbers. Normally we get around this by using "signed integers", which is something we [cover in an appendix](http://intermezzos.github.io/book/appendix/signed-and-unsigned.html). The point is we have an unsigned integer here, which means we're limited to representing only positive numbers. This means we can't literally represent -(`magic_number` + `architecture` + `header_length`) in our field.
>
> If you look closely at the spec you'll notice it's strangely worded: it's asking for a value that when added to other values has a sum of zero. It's worded this way because integers have a limit to the size of numbers they can represent, and when you go over that size, the values wrap back around to zero. So 0xFFFFFFFF + 1 is.... 0x00000000. This is a hardware limitation: technically it's doing the addition correctly, giving us the 33-bit value 0x100000000, but we only have 32 bits to store things in so it can't actually tell us about that `1` in the most significant digit position! We're left with the rest of the digits, which spell out zero.
>
> So what we can do here is "trick" the computer into giving us zero when we do the addition. Imagine for the sake of argument that `magic_number` + `architecture` + `header_length` somehow works out to be 0xFFFFFFFE. The number we'd add to that in order to make 0 would be 0x00000002. This is 0x100000000-0xFFFFFFFE, because 0x100000000 technically maps to 0 when we wrap around. So we replace 0xFFFFFFFE in our contrived example here with `magic_number` + `architecture` + `header_length`. This gives us:
> `dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))`

### Ending tag

After the checksum you can list a series of “tags”, which is a way for the OS to
tell the bootloader to do some extra things before handing control over to the
OS, or to give the OS some extra information once started. We donʼt need any of
that yet, though, so we just need to include the required “end tag”, which looks
like this:

```x86asm
header_start:
    dd 0xe85250d6                ; magic number
    dd 0                         ; protected mode code
    dd header_end - header_start ; header length

    ; checksum
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    ; required end tag
    dw 0    ; type
    dw 0    ; flags
    dd 8    ; size
header_end:
```

Here we use `dw` to define a ‘word’ instead of just data. Remember a ‘word’ is 16
bits or 2 bytes on the x86\_64 architecture. The multiboot specification demands
that this be exactly a word. You’ll find that this is super common in operating systems:
the exact size and amount of everything matters. It’s just a side-effect of
working at a low level.

### The Section

We have one last thing to do: add a ‘section’ annotation. We’ll talk more about
sections later, so for now, just put what I tell you at the top of the file.

Here’s the final file:

```x86asm
section .multiboot_header
header_start:
    dd 0xe85250d6                ; magic number
    dd 0                         ; protected mode code
    dd header_end - header_start ; header length

    ; checksum
    dd 0x100000000 - (0xe85250d6 + 0 + (header_end - header_start))

    ; required end tag
    dw 0    ; type
    dw 0    ; flags
    dd 8    ; size
header_end:
```

That’s it! Congrats, you’ve written a multiboot compliant header. It’s a lot of
esoterica, but it’s pretty straightforward once you’ve seen it a few times.

## Assembling with `nasm`

We can’t use this file directly, we need to turn it into binary. We can use a
program called an ‘assembler’ to ‘assemble’ our assembly code into binary code.
It’s very similar to using a ‘compiler’ to ‘compile’ our source code into
binary. But when it’s assembly, people often use the more specific name.

We will be using an assembler called `nasm` to do this. You should invoke
`nasm` like this:

```bash
$ nasm -f elf64 multiboot_header.asm
```

The `-f elf64` says that we want to output a file using the `elf64` file
*f*ormat. ELF is a particular executable format that’s used by various UNIX
systems, and we’ll be using it too. The executable format just specifies how
exactly the bits will be laid out in the file. For example, will there be a
magic number at the beginning of the file for easier error checking? Or where in
the file do we specify whether our code and data is in a 32-bit or 64-bit
format? There are other formats, but ELF is pretty good.

After you run this command, you should see a `multiboot_header.o` file in
the same directory. This is our ‘object file’, hence the `.o`. Don't let the
word ‘object’ confuse you. It has nothing to do with anything object oriented.
‘Object files’ are just binary code with some metadata in a particular format -
in our case ELF. Later, we’ll take this file and use it to build our OS.

## Summary

Congratulations! This is the first step towards building an operating system.
We learned about the boot process, the GRUB bootloader, and the Multiboot
specification. We wrote a Multiboot-compliant header file in assembly code, and
used `nasm` to create an object file from it.

Next, we’ll write the actual code that prints “Hello world” to the screen.
