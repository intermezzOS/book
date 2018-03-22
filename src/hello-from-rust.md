# Hello from Rust!

Okay, time for the big finale: printing our `OKAY` from Rust. First, let's
change our `Makefile` to add the Rust code into our assembly code. We can build
on the steps we did earlier. Here's a new rule to add to the `Makefile`:

```make
cargo:
	xargo build --release --target x86_64-unknown-intermezzos-gnu
```

This uses `xargo` to automatically cross-compile (remember, we're trying to
compile _from_ our OS _to_ intermezzOS) `libcore` for us. Easy! Let's give it a
try:

```bash
$ make cargo
xargo build --release --target x86_64-unknown-intermezzos-gnu
 Downloading https://static.rust-lang.org/dist/2016-09-25/rustc-nightly-src.tar.gz
   Unpacking rustc-nightly-src.tar.gz
   Compiling sysroot for x86_64-unknown-intermezzos-gnu
   Compiling core v0.0.0 (file:///home/steve/.xargo/src/libcore)
   Compiling alloc v0.0.0 (file:///home/steve/.xargo/src/liballoc)
   Compiling rustc_unicode v0.0.0 (file:///home/steve/.xargo/src/librustc_unicode)
   Compiling rand v0.0.0 (file:///home/steve/.xargo/src/librand)
   Compiling collections v0.0.0 (file:///home/steve/.xargo/src/libcollections)
   Compiling intermezzos v0.1.0 (file:///home/steve/src/intermezzOS/kernel/chapter_05)
$
```

Success! It should all build properly. There's one more thing I'd like to note
about this makefile: in a strict sense, it will try and rebuild too much. But
watch what happens if we try to build a second time:

```bash
$ make cargo
xargo build --release --target x86_64-unknown-intermezzos-gnu
$
```

We issued some commands, but didn't actually compile anything. With this
layout, we're letting Cargo worry if stuff needs to be rebuilt. This makes
our Makefile a bit easier to write, and also a bit more reliable. Cargo
knows what it needs to do, let's just trust it to do the right thing.

Now that we have it building, we need to modify the rule that builds the kernel
to include `libintermezzos.a`:

```makefile
target/kernel.bin: target/multiboot_header.o target/boot.o src/asm/linker.ld cargo
        ld -n -o target/kernel.bin -T src/asm/linker.ld target/multiboot_header.o target/boot.o target/x86_64-unknown-intermezzos-gnu/release/libintermezzos.a
```

And then we can build:

```bash
$ make
mkdir -p target
nasm -f elf64 src/asm/multiboot_header.asm -o target/multiboot_header.o
mkdir -p target
nasm -f elf64 src/asm/boot.asm -o target/boot.o
xargo build --release --target x86_64-unknown-intermezzos-gnu
   Compiling intermezzos v0.1.0 (file:///home/steve/src/intermezzOS/kernel/chapter_05)
ld -n -o target/kernel.bin -T src/asm/linker.ld target/multiboot_header.o target/boot.o target/x86_64-unknown-intermezzos-gnu/release/libintermezzos.a
$
```

Hooray! We are now successfully building our assembly code and our Rust code, and then putting them together.

Now, to write our Rust. Add this function to `src/lib.rs`:

```rust
#[no_mangle]
pub extern fn kmain() -> ! {

    loop { }
}
```

This is our main function, which is traditionally called `kmain()`, for 'kernel
main.' We need to use the `#[no_mangle]` and `pub extern` annotations to indicate
that we're going to call this function like we would call a C function. The `-> !`
indicates that this function never returns. And in fact, it does not return:
the body is an infinite `loop`.

I'm going to pause here to mention that while I won't totally assume you're a
Rust expert, this is more of an OS tutorial than a Rust tutorial. If anything
about the Rust is confusing, I suggest you read over the [official book] to get
an actual introduction to the language. It's tough enough explaining operating
systems as it is without needing to fully explain a language too. But if you're
an experienced programmer, you might be able to get away without it.

[official book]: http://doc.rust-lang.org/book

Anyway, our `kmain()` doesn't do anything. But let's try calling it anyway.
Modify `src/asm/boot.asm`, removing all of the `long_mode_start` stuff,
and changing the `jmp` line in `start` to look like this:

```x86asm
    ; jump to long mode!
    jmp gdt64.code:kmain
```

Finally, add this line to the top of the file:

```x86asm
extern kmain
```

This line says that we'll be defining `kmain` elsewhere: in this case, in Rust!
And so we also change our `jmp` to jump to `kmain`.

If you type `make run`, everything should compile and run, but then not display
anything. We didn't port over the message! Open `src/lib.rs` and change `kmain()`
to look like this:

```rust
#[no_mangle]
pub extern fn kmain() -> ! {
    unsafe {
        let vga = 0xb8000 as *mut u64;

        *vga = 0x2f592f412f4b2f4f;
    };

    loop { }
}
```

The first thing you'll notice is the `unsafe` annotation. Yes, while one of
Rust's defining features is safety, we'll certainly be making use of `unsafe`
in our kernel. However, we'll be using less than you think. While this is just
printing `OKAY` to the screen, our intermediate VGA driver will be using the
exact same amount, with a lot more safe code on top.

In this case, the reason we need `unsafe` is the next two lines: we create a
pointer to `0xb8000`, and then write some numbers to it. Rust cannot know that
this is safe; if it did, it would have to understand that we are a kernel,
and understand the VGA specification. Having a programming language understand
VGA at that level would be a bit too much. So instead, we have to use unsafe.
Such is life.

However! We are now ready. We've worked really hard for this. Get pumped!!!

```bash
$ make run
```

If all goes well, this will print `OKAY` to your screen. But you'll have done
it with Rust! It only took us five chapters to get here!

This is just the beginning, though. At the end of the next chapter, your
main function will look like this, instead:

```rust
# #[macro_export]
# macro_rules! kprintln {
#     ($ctx:ident, $fmt:expr) => ();
# }
#
#[no_mangle]
pub extern fn kmain() -> ! {
    kprintln!(CONTEXT, "Hello, world!");

    loop { }
}
```

But for now, kick back and enjoy what you've done. Congratulations!
