# Creating our first crate

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

[hosts and targets]: setup.html#Hosts%20&%20Targets

Create a file named `x86_64-unknown-intermezzos-gnu.json`, and put this in it:

```json
{
	"arch": "x86_64",
	"cpu": "x86-64",
	"data-layout": "e-m:e-i64:64-f80:128-n8:16:32:64-S128",
	"llvm-target": "x86_64-unknown-none-gnu",
	"linker-flavor": "gcc",
	"no-compiler-rt": true,
	"os": "intermezzos",
	"target-endian": "little",
	"target-pointer-width": "64",
	"target-c-int-width": "32",
	"features": "-mmx,-fxsr,-sse,-sse2,+soft-float",
	"disable-redzone": true,
	"eliminate-frame-pointer": false
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
I should stop writing this and go work on that... anyway. I digress.

To use this target specification, we pass `--target` to Cargo:

```bash
$ cargo build --release --target=x86_64-unknown-intermezzos-gnu
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

## Building libcore with xargo

So how do we get a copy of `libcore` for intermezzOS? The answer is [`xargo`]. It's
a wrapper around Cargo that knows how to read a `target.json` file and automatically
cross-compile `libcore`, then set up Cargo to use it.

[`xargo`]: https://github.com/japaric/xargo

Let's modify `src/lib.rs` to get rid of that useless test, and to say we don't want to
use the standard library:

```rust,compile_fail
#![no_std]
```

That's it, just an empty library with one little annotation. Now we're ready to
build. Well, almost, anyway:

```bash
$ cargo install xargo
<snip, let's not include all of this output here. It should build successfully though.>
```

In order for `xargo` to work, it needs a copy of Rust's source code; that's how it
builds a custom `libcore` for us. Add it with `rustup`:

```bash
$ rustup component add rust-src
```

And now let's build:

```bash
$ xargo build --release --target=x86_64-unknown-intermezzos-gnu
   Compiling sysroot for x86_64-unknown-intermezzos-gnu
   Compiling core v0.0.0 (file:///home/steve/.xargo/src/libcore)
   Compiling alloc v0.0.0 (file:///home/steve/.xargo/src/liballoc)
   Compiling rustc_unicode v0.0.0 (file:///home/steve/.xargo/src/librustc_unicode)
   Compiling rand v0.0.0 (file:///home/steve/.xargo/src/librand)
   Compiling collections v0.0.0 (file:///home/steve/.xargo/src/libcollections)
   Compiling intermezzos v0.1.0 (file:///home/steve/src/intermezzOS/kernel/chapter_05)
error: language item required, but not found: `panic_fmt`
error: language item required, but not found: `eh_personality`
error: aborting due to 2 previous errors
error: Could not compile `intermezzos`.
```

So why'd we get yet another error? For that, we need to understand a Rust
feature, panics.

## Panic == abort

The specific error we got said "language item required, but not found". Rust
lets you implement bits of itself through these language items. `libcore`
defines most of them, but the last two, `panic_fmt` and `eh_personality`,
need to be defined by us.

Both of these language items involve a feature of Rust called 'panics.'
Here's a Rust program that panics:

```rust,should_panic
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

```rust,ignore
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
$ xargo build --release --target=x86_64-unknown-intermezzos-gnu
   Compiling intermezzos v0.1.0 (file:///path/to/your/kernel)
$
```

Success! We've built some Rust code, cross-compiled to our kernel, and we're
ready to go.

But now, we've got all of our Rust-related stuff in `src`. But the rest of our
files are still strewn around in our top-level directory. Let's do a little bit
of cleaning up.

## Some reorganization

We have a couple of different ways that we could re-organize the assembly
language. If we were planning on making our OS portable across architectures, a
good solution would be to move it into `src/arch/arch_name`. That way, we could
have `src/arch/x86/`, `src/arch/x86_64`, etc. However, we're not planning on
doing that any time soon. So let's keep it a bit simpler for now:

```bash
$ mkdir src/asm
$ mv boot.asm src/asm
$ mv multiboot_header.asm src/asm/
$ mv linker.ld src/asm/
$ mv grub.cfg src/asm/
```

Now, we've got everything tucked away nicely. But this has broken our build terribly:

```bash
$ make
make: *** No rule to make target 'multiboot_header.asm', needed by 'build/multiboot_header.o'.  Stop.
```

Let's fix up our `Makefile` to work again.

## Fixing our Makefile

The first thing we need to do is fix up the paths:

```makefile
build/multiboot_header.o: src/asm/multiboot_header.asm
        mkdir -p build
        nasm -f elf64 src/asm/multiboot_header.asm -o build/multiboot_header.o

build/boot.o: src/asm/boot.asm
        mkdir -p build
        nasm -f elf64 src/asm/boot.asm -o build/boot.o

build/kernel.bin: build/multiboot_header.o build/boot.o src/asm/linker.ld
        ld -n -o build/kernel.bin -T src/asm/linker.ld build/multiboot_header.o build/boot.o

build/os.iso: build/kernel.bin src/asm/grub.cfg
        mkdir -p build/isofiles/boot/grub
        cp src/asm/grub.cfg build/isofiles/boot/grub
        cp build/kernel.bin build/isofiles/boot/
        grub-mkrescue -o build/os.iso build/isofiles
```

Here, we've added `src/asm/` to the start of all of the files that we moved.
This will build:

```bash
$ make
mkdir -p build
nasm -f elf64 src/asm/multiboot_header.asm -o build/multiboot_header.o
mkdir -p build
nasm -f elf64 src/asm/boot.asm -o build/boot.o
ld -n -o build/kernel.bin -T src/asm/linker.ld build/multiboot_header.o build/boot.o
$
```

Straightforward enough. However, now that we have Cargo, it uses the `target`
directory, and we're building our assembly into the `build` directory. Having
two places where our object files go is less than ideal. So let's change it to
output into `target` instead. Our `Makefile` will then look like this:

```makefile
default: build
        
build: target/kernel.bin

.PHONY: default build run clean

target/multiboot_header.o: src/asm/multiboot_header.asm
        mkdir -p target
        nasm -f elf64 src/asm/multiboot_header.asm -o target/multiboot_header.o

target/boot.o: src/asm/boot.asm
        mkdir -p target
        nasm -f elf64 src/asm/boot.asm -o target/boot.o

target/kernel.bin: target/multiboot_header.o target/boot.o src/asm/linker.ld
        ld -n -o target/kernel.bin -T src/asm/linker.ld target/multiboot_header.o target/boot.o

target/os.iso: target/kernel.bin src/asm/grub.cfg
        mkdir -p target/isofiles/boot/grub
        cp src/asm/grub.cfg target/isofiles/boot/grub
        cp target/kernel.bin target/isofiles/boot/
        grub-mkrescue -o target/os.iso target/isofiles

run: target/os.iso
        qemu-system-x86_64 -cdrom target/os.iso

clean: 
        rm -rf target
```

However, that last rule is a bit suspect. It does work just fine, `make clean`
will do its job. However, Cargo can do this for us, and it's a bit nicer.
Modifying the last rule, we end up with this:

```makefile
default: build
        
build: target/kernel.bin

.PHONY: default build run clean

target/multiboot_header.o: src/asm/multiboot_header.asm
        mkdir -p target
        nasm -f elf64 src/asm/multiboot_header.asm -o target/multiboot_header.o

target/boot.o: src/asm/boot.asm
        mkdir -p target
        nasm -f elf64 src/asm/boot.asm -o target/boot.o

target/kernel.bin: target/multiboot_header.o target/boot.o src/asm/linker.ld
        ld -n -o target/kernel.bin -T src/asm/linker.ld target/multiboot_header.o target/boot.o

target/os.iso: target/kernel.bin src/asm/grub.cfg
        mkdir -p target/isofiles/boot/grub
        cp src/asm/grub.cfg target/isofiles/boot/grub
        cp target/kernel.bin target/isofiles/boot/
        grub-mkrescue -o target/os.iso target/isofiles

run: target/os.iso
        qemu-system-x86_64 -cdrom target/os.iso

clean: 
        cargo clean
```

Not too bad! We're back where we started. Now, you may notice a bit of
repetition with our two `.o` file rules. We could make a lot of use of some
more advanced features of Make, and DRY our code up a little. However, it's not
that bad yet, and it's still easy to understand. Makefiles can get very
complicated, so I like to keep them simple. If you're feeling ambitious, maybe
investigating some more features of Make and tweaking this file to your liking
might be an interesting diversion.
