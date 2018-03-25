# Setting up a development environment

Frankly, one of the hardest parts of starting an operating system is getting a
development environment going. Normally, you’re doing work on the same
operating system you’re developing for, and we don’t have that luxury. Yet!

There is a convention called a ‘target triple’ to describe a particular
platform. It’s a ‘triple’ because it has three parts:

```text
arch-kernel-userland
```

So, a target triple for a computer which has an x86-64 bit processor running a
Linux kernel and the GNU userland would look like this:

```text
x86_64-linux-gnu
```

However, it can also be useful to know the operating system as well, and so
the ‘triple’ part can be extended to include it:

```text
x86_64-unknown-linux-gnu
```

This is for some unknown Linux. If we were targeting Debian specifically, it
would be:

```text
x86_64-debian-linux-gnu
```

Since it’s four parts, it’s called a ‘target’ rather than a ‘target triple’,
but you’ll still hear some people call it a triple anyway.

Kernels themselves don’t need to be for a specific userland, and so you’ll
see ‘none’ get used:

```text
x86_64-unknown-none
```

## Hosts & Targets

The reason that they’re called a ‘target’ is that it’s the architecture you’re
compiling _to_. The architecture you’re compiling _from_ is called the ‘host
architecture’.

If the target and the host are the same, we call it ‘compiling’. If they are
different, we call it ‘cross-compiling’. So you’ll see people say things like

> I cross-compiled from x86\_64-linux-gnu to x86-unknown-none.

This means that the computer that the developer was using was a 64-bit
GNU/Linux machine, but the final binary was for a 32-bit x86 machine with no
OS.

So we need a slightly special environment to build our OS: we need to
cross-compile from whatever kind of computer we are using to our new target.

## Cheat codes

... but we can also cheat. It’s okay to cheat. Well, in this case, it’s really
only okay at the start. We’ll eventually _have_ to cross-compile, or things
will go wrong.

Here’s the cheat: if you are developing on an x86\_64 Linux machine, and you’re
not using any special Linux kernel features, then the difference between
`x86_64-linux-gnu` and `x86_64-unknown-none` is really just theoretical. It
will still technically _work_. For now.

This is a common pitfall with new operating system developers. They’ll start
off with the cheat, and it will come back to haunt them later. Don’t worry;
I will actually show you how to fix things before they go wrong. Knowing the
difference here is still useful.

## Installing Rust

First, you need to get a copy of Rust! There's one catch though: you'll need to
get _exactly_ the correct version of Rust. Unfortunately, for OS development,
we need to take advantage of some cutting-edge features that aren't yet stable.

Luckily, the Rust project has a tool that makes it easy to switch between Rust
versions: `rustup`. You can get it from the [install
page](http://rust-lang.org/install.html) of the Rust website.

By default, `rustup` uses stable Rust. So let's tell it to install nightly:

```bash
$ rustup update nightly
```

This installs the current version of nightly Rust. We run all of the examples
in this book under continuous integration, so we should know if something
changes in nightly Rust and breaks. But please [file bugs] if something doesn't
work.

[file bugs]: https://github.com/intermezzOS/book/issues/new

Because nightly Rust includes unstable features, you shouldn't use it unless
you really need to, which is why `rustup` allows you to override the default
version only when you're in a particular directory. We don't have a directory
for our project yet, so let's create one:

```bash
$ mkdir intermezzOS
$ cd intermezzOS
```

A fun way to follow along is to pick a different name for your kernel, and
then change it as we go. Call your kernel whatever you want. intermezzOS was
almost called ‘Nucleus’, until I found out that there’s already a kernel with
that name that’s installed on billions of embedded devices. Whoops!

Inside your project directory, set up the override:

```bash
$ rustup override add nightly
```

Nice and easy. We can't get the version wrong; `rustup` handles it for us.
