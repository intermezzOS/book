# A Rust kmain()

At long last, we're ready to move on to some Rust code! This is ostensibly a
"write a kernel in Rust" tutorial, but we haven't gotten to any Rust code yet.
We're out of the woods with assembly; at least for a while. We'll be writing a
bit more in the future, but for now, let's forget about all of that.

## Installing Rust

First, you need to get a copy of Rust! There's one catch though: you'll need to
get _exactly_ the correct version of Rust. Unfortunately, for OS development,
we need to take advantage of some cutting-edge features that aren't yet stable.
So in order for this to work, you have to be using the exact correct Rust. Don't
worry though, it's easy to do. Put this in your terminal:

```bash
$ curl https://sh.rustup.rs -sSf | sh
```

This will install `rustup`. At the time of this writing, `rustup` is in beta,
but it will be the de-facto way to get Rust from the Rust team. It also makes
it very easy to switch between different versions of Rust, and install
multiple copies of Rust, both of which are features that are of use to us. If
you do other Rust work, you won't want to be stuck with the version we use here!

To get the Rust we need, first type this:

```bash
$ rustup update nightly-2016-05-26
```

This installs the version of nightly Rust for May 26th, 2016. We'll try to keep
the book current and upgrade Rust periodically, so if you take a break and come
back to things, check back with this chapter to see if you need to upgrade.

Then, execute this:

```bash
$ rustup override add nightly-2016-05-26.
```

This sets up `rustup` to switch to the Rust we need whenever we're in this
directory. Nice and easy. We can't get the version wrong; `rustup` handles it
for us.

## Creating our first crate

Now that we've got Rust installed, time to write some Rust code! `rustup` has
also installed Cargo for us, Rust's build tool and package manager. Generate
a new Cargo package like this:

```bash
$ cargo init --name intermezzos
```

This will create a new package called '`intermezzos`' in the current directory.
We have some new files. First, `Cargo.toml`:

```toml
[package]
name = "intermezzos"
version = "0.1.0"
authors = ["Your Name <you@example.com>"]

[dependencies]
```

This file sets overall configuration for the package. You'll see your
information under `authors`, Cargo pulls it in from `git`, if you use it.
Otherwise, you can add it yourself, no big deal.

Next, `src/lib.rs`:

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
    }
}
```

Cargo has generated us a sample test suite. We don't need any of this though;
we won't be doing testing just yet. Let's try building the project:

```bash
$ cargo build
   Compiling intermezzos v0.1.0 (file:///path/to/your/kernel)
```

After this builds, we have one new file, `Cargo.lock`. What's in it isn't a big
deal; Cargo uses the file to pin our dependency versions, so its contents are
internal to Cargo.

That said, we need to make two more tweaks. Check out what's in the `target`
directory:

```bash
$ ls target/debug/
build  deps  examples  libintermezzos.rlib  native
```

Cargo has generated an `.rlib`, which is Rust's library format. However, we want
to generate a static library instead. Modify `Cargo.toml` to have a new section:

```toml
[package]
name = "intermezzos"
version = "0.1.0"
authors = ["Steve Klabnik <steve@steveklabnik.com>"]

[lib]
crate-type = ["staticlib"]

[dependencies]
```

This `crate-type` annotation tells Cargo we want to build a static library,
rather than the default `rlib`. Let's build again:

```bash
$ cargo clean
$ cargo build
   Compiling intermezzos v0.1.0 (file:///path/to/your/kernel)
note: link against the following native artifacts when linking against this static library
note: the order and any duplication can be significant on some platforms, and so may need to be preserved
note: library: dl
note: library: pthread
note: library: gcc_s
note: library: c
note: library: m
note: library: rt
note: library: util
```

Whew! We get some debugging output. Don't worry about that; we'll be getting
rid of it in a bit. For now, though, we can see that Cargo has built the static
library:

```bash
$ ls target/debug/
build  deps  examples  libintermezzos.a  native
```

We now have a `.a` file. This is exactly what we want. Also, make note of this
path: `target/debug`. That's where Cargo puts output for debugging builds. We
probably should use a release build instead: `cargo build --release` will
give us that, and put the output in `target/release`.

## Creating a target

Remember back in the setup chapters, where we talked about [hosts and targets]?
We need to do the equivalent for Rust. We _could_ leave things where they are,
but that would cause us problems later. So let's just get it out of the way
now, while we're doing all this other setup.

[hosts and targets]: book/setup.html#Hosts%20&%20Targets

Create a file named `x86_64-unknown-intermezzos-gnu.json`, and put this in it:

```json
{
        "llvm-target": "x86_64-unknown-none-gnu",
        "target-endian": "little",
        "target-pointer-width": "64",
	"data-layout": "e-m:e-i64:64-f80:128-n8:16:32:64-S128",
        "os": "intermezzos",
        "arch": "x86_64",
        "pre-link-args": [ "-m64" ],
        "cpu": "x86-64",
        "features": "-mmx,-sse,-sse2,-sse3,-ssse3",
        "disable-redzone": true,
        "eliminate-frame-pointer": false,
        "linker-is-gnu": true,
        "no-compiler-rt": true,
        "archive-format": "gnu"
}
```

Unlike `gcc`, where you have to build a cross-compiler by actually building a
copy of the compiler, Rust lets you cross-compile by creating one of these
"target specifications." This specification declares all of the various options
that need to be set up for this target to work.

There are two parts of this target specification I'd like to call out in general.
The first is `features`. We have `-mmx,-sse`, and such. This controls the assembly
features that we can generate, in other words, we will _not_ be generating MMX or
SSE instructions. These handle floating point, but they're problematic in a kernel.
Basically, we don't _need_ to use them for anything, and they make some things a
lot more difficult. For one thing, we have to explicitly enable SSE support through
some more assembly code, which is annoying, and when we deal with interrupts in a
later chapter, they'll pose some difficulty there, as well. So let's turn them off.
This isn't just a toy kernel thing; Linux also turns off SSE.

The second is `disable-redzone`. This is a feature of the x86\_64 ABI which is
similar: it's useful for application code, but causes problems in the kernel. You
can think of the red zone as a kind of "scratch space," 128 bytes that's hidden
inside of the stack frame. We don't want any of that in our kernel, so we turn it
off.

The rest of these options aren't particularly interesting. I would tell you to go
look them up in Rust's documentation, but it's sorely lacking at the moment. Maybe
I should stop writing this and go work on that... anway. I digress.

To use this target specification, we pass `--target` to Cargo:

```bash
$ cargo build --release --target=x86_64-unknown-intermezzos-gnu.json
   Compiling intermezzos v0.1.0 (file:///path/to/your/kernel)
error: can't find crate for `std` [E0463]
error: aborting due to previous error
error: Could not compile `intermezzos`.

To learn more, run the command again with --verbose.
```

Wait, that didn't work? If you think about it, this makes sense: we told Rust that
we wanted to compile our code for intermezzOS, but we haven't compiled a standard
library for it yet! In fact, we don't want a standard library: our operating system
is far from containing the proper features to support it. Instead, we only want
Rust's `libcore` library. This library contains just the essential stuff, without
all of the fancy features we can't support yet.

## Including libcore

Well... so, this part gets a bit messy. While `libcore` _is_ mostly ready for
kernel development, we decided to turn off floating point in our kernel. But
`libcore` assumes that we support floating point. So that's bad.

This is an area of ongoing negotiation between the OS dev community and the
Rust team. We're working on a solution. In the meantime, I've tried to solve
some of the pain for you to make this easier. Specifically, I've got
[a fork of libcore], ready for you to use. It is patched to not use floating
point anymore. All of us in the OS dev world share these patches around, and
update them when Rust gets updated. This is actually the reason why we have to
be so specific about our Rust version.

[a fork of libcore]: http://github.com/intermezzos/libcore

In order to use this fork, we need to clone it down:

```bash
$ git clone http://github.com/intermezzos/libcore build/libcore
Cloning into 'build/libcore'...
remote: Counting objects: 140, done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 140 (delta 3), reused 0 (delta 0), pack-reused 132
Receiving objects: 100% (140/140), 362.70 KiB | 166.00 KiB/s, done.
Resolving deltas: 100% (52/52), done.
Checking connectivity... done.
```

... and then build it...

```bash
# copy the target file in so we can build for our target
$ cp x86_64-unknown-intermezzos-gnu.json build/libcore 

$ cd build/libcore

# This is the correct version for the Rust we have, so let's
# set it explicitly to be safe
$ git reset --hard 02e41cd5b925a1c878961042ecfb00470c68296b
HEAD is now at 02e41cd Reintroduce panic == abort

# Finally, build with all the correct options
$ cargo build --release --features disable_float --target=x86_64-unknown-intermezzos-gnu.json
   Compiling core v0.1.0 (file:///path/to/your/kernel/build/core)

# Switch back to our source directory
$ cd ../..
```

Whew! That'sa  lot of work. Don't worry, we'll be modifying our `Makefile` to do this
automatically soon.

Let's modify `src/lib.rs` to get rid of that useless test, and to say we don't want to
use the standard library:

```rust
#![no_std]
```

That's it, just an empty library with one little annotation. Now we're ready to
build. Well, almost, anyway:

```bash
$ RUSTFLAGS="-L build/libcore/target/x86_64-unknown-intermezzos-gnu/release" cargo build --target x86_64-unknown-intermezzos-gnu.json
   Compiling intermezzos v0.1.0 (file:///path/to/your/kernel)
error: language item required, but not found: `panic_fmt`
error: language item required, but not found: `eh_personality`
error: aborting due to 2 previous errors
error: Could not compile `intermezzos`.
```

Whew! Our `cargo build` was so easy at first! `RUSTFLAGS` is a special
environment variable that will modify how Cargo calls `rustc` for every crate
in the build. We need it to set the path to where our modified `libcore` is.

So why'd we get yet another error? For that, we need to understand a Rust
feature, panics.

## Panic == abort

The specific error we got said "language item required, but not found". Rust
lets you implement bits of itself through these language items. `libcore`
defines most of them, but the last two, `panic_fmt` and `eh_personality`,
need to be defined by us.

Both of these language items invovle a feature of Rust called 'panics.'
Here's a Rust program that panics:

```rust
fn main() {
     panic!("oh no!");
}
```

When the `panic!` macro executes, it will stop the current thread from
executing, and unwind the stack. This is something we really don't want
in a kernel. Rust lets us turn this off, though, in our `Cargo.toml`:

```toml
[profile.release]
panic = "abort"
```

By adding this to our `Cargo.toml`, Rust will abort when it hits a panic,
rather than unwind. That's good! However, we still need to define those
language items. Modify `src/lib.rs` to look like this:

```rust
#![feature(lang_items)]
#![no_std]

#[lang = "eh_personality"]
extern fn eh_personality() {
}

#[lang = "panic_fmt"]
extern fn rust_begin_panic() -> ! {
    loop {}
}
```

Defining language items is a nightly-only feature, so we add the `![feature]`
flag to turn it on. Then, we define two functions, and annotate them with
the `#[lang]` attribute to inform Rust that these functions are our language
items. `eh_personality()` doesn't need to do anything, but `rust_begin_panic()`
should never return, so we put in an inifinite `loop`.

Let's try compiling again:

```bash
$ RUSTFLAGS="-L build/libcore/target/x86_64-unknown-intermezzos-gnu/release" cargo build --target x86_64-unknown-intermezzos-gnu.json
   Compiling intermezzos v0.1.0 (file:///path/to/your/kernel)
$
```

Success! We've built some Rust code, cross-compiled to our kernel, and we're
ready to go.

But now, we've got all of our Rust-related stuff in `src`. But the rest of our
files are still strewn around in our top-level directory. Let's do a little bit
of cleaning up.

## Some reorganization

## Modifying our Makefile

## Hello from Rust!
