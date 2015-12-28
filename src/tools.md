# What tools will we use?

Before we can make a kernel, we need to figure out the tools we’re going to
use. The first question, of course, is what programming language?

In our case, we’re going to use two. The first one is the language that
_every_ kernel must use: assembly language.

## Assembly

Assembly language gives us direct access to a specific machine. If the basis of
computer science is abstraction, the very bottom of the software abstraction layer
is assembly. Below it lies only hardware and physics.

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
don't worry. We'll be taking assembly language step by step.

We can run it like this:

```bash
$ nasm -f elf64 foo.asm # assemble into foo.o
$ ld foo.o              # link into a.out
$ ./a.out               # run it
$ echo $?               # print out the exit code
10
$
```

You can write entire kernels in assembly if you want to. It’s not as bad as it
may sound. At the very beginning, we will _have_ to use assembly. But not very
much. It takes about 100 lines total, to start. Completely manageable.

## Rust

We will augment our assembly with code written in
[Rust](https://www.rust-lang.org/). In fact, we will be trying to get to
Rust-land as quickly as we possibly can. Rust is a really great programming
language, and it’s pretty great for writing operating systems. It has some
rough edges, but they’re not too big of a deal.

Rust will allow us to write:

```rust
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
