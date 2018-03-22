# What tools will we use?

Before we can make a kernel, we need to figure out the tools we’re going to
use. The first question, of course, is what programming language?

In our case, we’re going to use two. The first one is the language that
_every_ kernel must use: assembly language.

## Assembly

Assembly language gives us direct access to a specific machine. If the basis of
computer science is abstraction, the very bottom of the software abstraction layer
is assembly. Below it lies only hardware and physics.

There are many kinds of assembly languages each targeted at different
‘instruction set’ architectures (also known as ISA or simply as instruction sets).
These instruction sets are the list of commands that a given CPU can understand. For
example, if your computer has an Intel Pentium processor of some kind then it
understands the x86 instruction set. So if you were to write assembly for another
instruction set (say MIPS or ARM), you would not be able to run it on your computer.

This is one of the reasons we'll want to get away from the assembly world as
fast as possible. If we want our kernel to work for a bunch of different
architectures, any code we end up writing in assembly will need to be duplicated.
However, if we use a more high-level language like C, C++ or the language we'll
really be using, Rust, we can write the code once and cross-compile
to different architectures.

Assembly language looks like this:

```x86asm
; foo.asm

section .data
global _start

_start:
    mov rax, 0
loop:
    add rax, 1
    cmp rax, 10
    jne loop

    mov rbx, rax
    mov rax, 1
    int 80h
```

This is a little program in assembly language. If it looks totally alien to you,
don't worry. While we could write our entire kernel in assembly, we'll only be
learning as much assembly as we need to not have to use it any more.

When you write assembly language you are actually directly manipulating the
individual registers of the CPU and memory inside of RAM and other hardware
devices like CD drives or display screens.

> **By the way...**
>
> CPUs are composed of registers each of which can only hold small amounts of data.
> The amount of data a register can hold dictates what type of CPU the register
> belongs to. If you didn't know why your machine is classified as either 32 bit
> or 64 bit it's because the machine's registers can either hold 32 bits of data at a
> time or 64 bits at a time.

In assembly we can only do very simple things: move data between registers or
to/from RAM; perform simple arithmetic like addition, subtraction, multiplication
and division; compare values in different registers, and based on these comparisons
jump to different points in our code (à la GOTO). Fancy high level concepts
like while loops and if statements, let alone garbage collection are nowhere to be
found. Even functions as you know them aren't really supported in assembly.
Each assembly program is just a bunch of data in registers or in memory and a
list of instructions, carried out one after the other.

For instance, in our code above we used the `mov` instruction several times to
move values into specific registers with weird names like `rax` and `rbx`. We
used the `cmp` instruction to compare the value inside of the `rax` register
with the number `10`. We used the `jne` instruction to jump to another part of
our code if the numbers we just compared were not equal. Finally we used the `int`
instruction to trigger a hardware *int*errupt.

Again, you don't need to fully understand this program at this point. Right now
you should just have an impression for how assembly is composed of simple
instructions that do very simple things.

When it comes time to write some actual assembly code we'll touch on all this again.

Let's run this little program:

```bash
$ nasm -f elf64 foo.asm # assemble into foo.o
$ ld foo.o              # link into a.out
$ ./a.out               # run it
$ echo $?               # print out the exit code
10
$
```

Don't worry too much about what programs we're using to actually compile (or
‘assemble’ as it's known in the assembly world) our program. We'll be going
over each one of these commands and explaining what they are and how to use
them.

## Rust

We will augment our assembly with code written in
[Rust](https://www.rust-lang.org/). In fact, we will be trying to get to
Rust-land as quickly as we possibly can. Rust is a really great programming
language, and it’s pretty great for writing operating systems. It has some
rough edges, but they’re not too big of a deal.

Rust will allow us to write:

```rust,should_panic
// foo.rs

use std::process;

fn main() {
    let mut a = 0;

    for _ in 0..10 {
        a = a + 1;
    }

    process::exit(a);
}
```

This does the same thing as our assembly code:

```bash
$ rustc foo.rs # compile our Rust code to foo
$ ./foo        # run it
$ echo $?      # print out the exit code
10
$
```

That Rust code probably looks more like a programming language you’ve used in
the past. It’s a lot nicer to write complex things in a higher-level
programming language like Rust. That said, virtually all languages are
higher-level than assembly, so that’s not saying all that much. Rust is still a
low-level language by many standards.

So why choose Rust? Well, I’m picking it for two reasons:

1) I love it.
2) There aren’t a lot of kernels in it yet.

There are a suprising number of people working on kernels in Rust. But since
it’s a newer language, there aren’t nearly as many as for older, more
established languages.

## Do I need to be a wizard?

No, you do not. A common theme of this project is “this is all we’ll need to
know about this topic for now.” There’s no reason that you need to absolutely
master everything before going forward. For example, in order to get Rust
going, we need only about 100 lines of assembly, as mentioned above. Do you
need to be a complete expert in assembly language to understand those well
enough to keep going? Not at all. Will learning more about it help? Absolutely!

There’s nobody that’s monitoring your credentials to see if you’re allowed to
move on. Do it at your own pace. Skip stuff. Come back when you don’t
understand what’s going on. Try it, wait a week, and then try it again.

There’s no wrong way to do this stuff, including by being a beginner. Everyone
was once. Don’t let anyone discourage you.
