# Moving to a "Bare Bones"

There are two more little steps we need to do before we move on to writing
more kernel code in Rust. It involves adding two crates to our project.

Cargo allows for us to easily depend on other packages of Rust code. We'll
be making use of a lot of this functionality; Rust has a surprisingly robust
operating system development library ecosystem.

## `rlibc`

The first package we'll be using is `rlibc`. Here's the deal: there are four
functions that are so primitive, LLVM (which the Rust compiler uses to generate
code) assumes that you already have them defined. For normal application
programming, this is true, but with our OS, we only have the code we've defined.
The `rlibc` crate contains Rust implementations of these functions.

To add the crate, open up your `Cargo.toml` and find the line with
`[dependencies]` on it. Modify it to add another line:

```toml
[dependencies]
rlibc = "1.0.0"
```

This tells Cargo that we want to depend on the `rlibc` package from
[crates.io](http://crates.io), Rust's open source package host.

## `x86`

Next, we have the `x86` crate. This package contains implementations of many
things that the x86 platform requires, that normally need special assembly
instructions. It wraps them up in Rust functions for ease of use, and also
provides some special data structures that are used when working with hardware.

Add another line to the `Cargo.toml`:

```toml
[dependencies]
rlibc = "1.0.0"
x86 = "0.7.0"
```

Next, run `make`:

```bash
$ make
$ make
cp x86_64-unknown-intermezzos-gnu.json target/libcore
cd target/libcore && cargo build --release --features disable_float --target=x86_64-unknown-intermezzos-gnu.json
RUSTFLAGS="-L target/libcore/target/x86_64-unknown-intermezzos-gnu/release" cargo build --release --target x86_64-unknown-intermezzos-gnu.json
    Updating registry `https://github.com/rust-lang/crates.io-index`
   Compiling num-traits v0.1.32
   Compiling raw-cpuid v2.0.1
   Compiling rlibc v1.0.0
   Compiling byteorder v0.3.13
   Compiling rustc-serialize v0.3.19
   Compiling phf_shared v0.7.15
   Compiling phf v0.7.15
   Compiling libc v0.2.12
   Compiling num-integer v0.1.32
   Compiling rand v0.3.14
   Compiling num-iter v0.1.32
   Compiling phf_generator v0.7.15
   Compiling phf_codegen v0.7.15
   Compiling num-complex v0.1.32
   Compiling csv v0.14.4
   Compiling num-bigint v0.1.32
   Compiling num-rational v0.1.32
   Compiling num v0.1.32
   Compiling serde v0.6.15
   Compiling serde_json v0.6.1
   Compiling x86 v0.7.0
   Compiling intermezzos v0.1.0 (file:///home/steve/src/intermezzOS/kernel/chapter_05)
ld -n -o target/kernel.bin -T src/asm/linker.ld target/multiboot_header.o target/boot.o target/x86_64-unknown-intermezzos-gnu/release/libintermezzos.a
```

Whew! Cargo knows not just the packages we're using, but all of the packages
that those packages are using. Some of the versions might be slightly
different, don't worry about that.

With these libraries included, we're ready to start writing some Rust code.
