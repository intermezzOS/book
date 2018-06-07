# From zero to `_start` in detail

We now have a little kernel. But we used a lot of tools to make it happen.
What do these tools actually *do*? This section is titled "in detail," but
it's really "in more detail than we've seen thus far." We're going to talk
about what happens, so you can dig in deeper if you're interested, but we
can't possibly cover every single bit in depth.

Here's the basic set of steps:

1. We write our kernel code.
2. We build it with `bootimage build`.
    1. This invokes `cargo-xbuild` to cross-compile `libcore`.
    2. It then invokes `cargo` to take our configuration and set up a build.
    3. Cargo invokes `rustc` to actually build the code.
    4. It then takes a precompiled 'bootloader' and our kernel and makes a `.bin` file.
3. We run it with `bootimage run`.
    1. This takes our `.bin` file, and runs Qeumu, using that `.bin` as its hard drive.

Whew! That's a lot of stuff. It's not completely different from writing any Rust
program, however: you write code, you build it, then you run it. Easy peasy.

Let's dig in a bit!

## We write our kernel code

This is the most straightforward step. Write the code! There is some subtlety
here, but we talked about it earlier in the chapter: we have to cross-compile
to our new platform. We remove the standard library. We configure both the
panic handler and the behavior for when a panic happens.

The rest of this book is largely about what to do during this step of
development, so we won't belabor it here. You type some code, hit save. Done.

## Building our code with `bootimage build`

Normally, we build Rust code with `cargo build`, but for an OS, we use
`bootimage` instead. This is a tool written by Phil Opperman (who we mentioned
in the preface), and it wraps up another tool, also written by Phil,
`cargo-xbuild`. That tool wraps Cargo. So, in the end, running `bootimage
build` is not too far away from running `cargo build` conceptually; it's mostly
that Cargo isn't extensible in the way we need at the moment, so we have
to wrap it.

### Invoking `cargo-xbuild` to cross-compile `libcore`

`cargo-xbuild`'s job is to cross compile Rust's `core` library. You see, Rust
has an interesting relationship between the language and libraries: some
important parts of the language are implemented as a library, not as a
built-in thing. These foundations, and some other goodies, are included in
the `core` library. So, before we can build our code, we need to build a copy
of `core` for our OS. `cargo-xbuild` makes this easy: it knows how to ask
`rustup` for a copy of `core`'s source code, and then builds it with our
custom target JSON.

### Invoking `cargo` to take our configuration and set up a build

Now that `core` is built, we can build our code! Cargo is *the* tool
in Rust for this task, so `cargo-xbuild` calls on it to do so. It
passes along our custom target JSON to make sure that we're outputting
a binary for the correct target.

### Invoking `rustc` to build the code

Cargo doesn't actually build our code: it invokes `rustc`, the Rust compiler,
to actually do the building. Right now our OS is very simple, but as it
grows, and as we split our code into packages, and use external packages,
it's much nicer to let Cargo handle calling `rustc` rather than doing it by
hand.

### Creating a `.bin` file

Now that we have our OS compiled, we need to prepare it for running. To do
so, `bootimage` creates a special file, called a `.bin` file. The `.bin`
stands for "binary", and it has no real format. It's just a bunch of binary
code. There's no structure, headings, layout, nothing. Just a big old bag of
bits.

However, that doesn't mean that what's in there is random. You see, when you
start up your computer, something called the BIOS runs first. The BIOS is
all-but hard-coded into your motherboard, and it runs some diagnostic checks
to make sure that everything is in order. It then runs the 'bootloader'.

This is either the most interesting or most boring part of this whole
enterprise. Almost all of this is piles and piles of backwards compatibility
hacks. Since early computers were very small, the bootloader only gets to
have *256 bytes* of stuff inside it. The eventual goal is to run your OS,
but there's a few other possibilities. For example, maybe you have more
than one OS on your computer, so the bootloader invokes a program that
lets you choose between them. Additionally, even on today's high-powered
CPUs, when the bootloader is invoked, they're in a backwards-compatible mode
that makes them think they're a processor from the 70s. That's right,
we basically didn't ever change the foundations here, simply piled new
things on top. "Oh, you think you're an 8-bit computer? Let's set up
16-bit mode. Oh, now you think you're a 16-bit computer? Let's set up
32-bit mode. Oh, now you think you're a 32-bit computer? Let's set up
64-bit mode." And *then* we can finally start our OS.

You may be wondering, "How does the bootloader do all this in only 256 bytes?
This quesiton itself is like 90 bytes!" The answer? Compatibility hacks.
Virutally all bootloaders today are multiple stages: the first tiny bootloader
sets up a secondary bootloader, and that one then can be larger and do more
work.

`bootimage` has a custom-written bootloader that puts your CPU into
64-bit mode, then calls the `_start` function of our OS. It assembles
the bootloader's code and our OSs' code into that one `.bin` file.

## Running our code with `bootimage run`

`bootimage run` takes our `.bin` file and passes it to Qemu, the emulator
we discussed earlier in the chapter. Qemu uses the `.bin` file as the
hard drive, and so when it starts up, its BIOS calls the bootloader
which calls our kernel. It also emulates the screen, so when we start
printing stuff to the screen, we'll see it pop up!

## Summary

There's more to explore here, but for now, we're not going to worry about
this stuff. It's very platform-specific, and mostly papering over legacy.
Instead, let's move forward and make our kernel actually *do* stuff, not
worry about how to put a processor into a specific mode.

In the next chapter, we'll print some characters on the screen!