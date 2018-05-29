# Setting up a development environment

Traditionally, getting a development environment set up for working on an
operating system is really hard. However, we have it pretty easy! We'll be
using the [Rust programming language] to develop our kernel, and thanks to
some awesome work by the language developers, as well as the homebrew Rust
operating system community, getting our environment set up is really easy.

[Rust programming language]: https://www.rust-lang.org/

To get going, you'll need a few tools:

* An editor or IDE to write the source code
* A compiler and other tools to turn that source code into binary code
* A virtual machine to try our OS out without installing it on our computer
* A project directory to do develop in

You can get all of these tools working on Windows, macOS, and Linux. Other
operating systems may work, but we've only tried this on these systems. This
section is the only one with OS-specific instructions; from here on out,
everything will be identical.

## An editor or IDE

This is needed, but is also largely a personal choice. You can use whatever
you'd like here, and that's 100% fine.

If you're not sure what to use, I do have two recommendations though. If
you prefer text editiors, give [Visual Studio: Code] a try. It's fairly
light-weight, but also has some nice features, and a great Rust plugin
provided by the Rust team.

[Visual Studio: Code]: https://code.visualstudio.com/

If you prefer IDEs, I'd suggest [Clion] with the Rust plugin. JetBrains
makes a suite of IDEs for a ton of languages, and their Rust support is
solid!

[Clion]: https://www.jetbrains.com/clion/

Really, anything works though: I use both of the above, and also `vim` at
times. It's just not a huge deal.

## The compiler and other tools

Next, we need to get the Rust compiler installed. To do that, head to
[Rust's install page] and follow the instructions. You can also install
Rust another way if you'd prefer, such as from your system's package
manager, but through the website is generally easiest.

[Rust's install page]: https://www.rust-lang.org/en-US/install.html

This will give you a tool called `rustup`, used to manage versions of
`rustc`, the Rust compiler, and Cargo, the package manager and
build tool. To check that this was installed properly, run these
three commands and check that you get some output:

```bash
$ rustup --version
$ rustc --version
$ cargo --version
```

If you do, everything's good!

### Stable vs. Nightly Rust

One of the reasons that it's easiest is that you can't use any version
of Rust to develop OSes; you need "nightly" Rust. Basically, Rust comes
in different flavors, and in order to develop operating systems, we need
to use some experimental, cutting-edge features. As such, we can't use
the stable Rust distribution, we need the nightly one.

To install nightly, do this:

```bash
$ rustup update nightly
```

This will download and install the nightly toolchain. We'll configure the
use of this toolchain automatically in the next section.

### Other tools

We need to install two more tools for building our OS. The first is
called `bootimage`, and its job is to take our kernel and produce a file
that our virtual machine (discussed in the next section) knows how to
run. To install it:

```bash
$ cargo install bootimage
```

To check that it installed correctly, run this:

```bash
$ bootimage --help
```

And you should see a help message printed to the screen.

The second tool is called `cargo-xbuild`. It extends Cargo, allowing us to
build Rust's core libraries for other OSes than the ones provided by the Rust
team. To install it:

```bash
$ cargo install cargo-xbuild
```

And to check that it was installed correctly, run this:

```bash
$ cargo xbuild --version
```

And make sure that you get some version output.

Additionally, to do its job, `cargo-xbuild` needs the source code for these
core libraries; to get those, run this:

```bash
$ rustup component add rust-src --toolchain=nightly
```

With that, we're all set up!

## A virtual machine

In order to see that your code runs, you *could* install it on a real computer,
but that is way too complex for regular development. Instead, we can use a virtual
machine to give our OS a try locally.

There's a few options, but for this, we'll use [Qemu]. Qemu works on all of our
platforms, and has enough features for us too. [Qemu's downloads page] should help
you get it installed.

[Qemu]: https://www.qemu.org/

[Qemu's downloads page]: https://www.qemu.org/download/

To check that it's working, try this:

```bash
$  qemu-system-x86_64 --version
```

And make sure it spits out a version number.

## A project directory

Finally, we need to put our source code somewhere. This can be wherever you'd like,
but for this book, we'll call ours `~/src/`. You'll see examples have this path in
the output, just to have something, but you can do this anywhere you'd like. We'll
call this "your project directory" a few times in the book, and we mean wherever you
decided to put stuff.

## That's it!

With that, we're done! Let's actually get some code going!