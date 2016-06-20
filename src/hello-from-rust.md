# Hello from Rust!

Okay, time for the big finale: printing our `OKAY` from Rust. First, let's
change our `Makefile` to add the Rust code into our assembly code. We can build
on the steps we did earlier. Here's some new rules to add to the `Makefile`:

```make
target/libcore:
        git clone http://github.com/intermezzos/libcore target/libcore
        cd target/libcore && git reset --hard 02e41cd5b925a1c878961042ecfb00470c68296b

target/libcore/target/x86_64-unknown-intermezzos-gnu/libcore.rlib: target/libcore
        cp x86_64-unknown-intermezzos-gnu.json target/libcore
        cd target/libcore && cargo build --release --features disable_float --target=x86_64-unknown-intermezzos-gnu.json

cargo: target/libcore/target/x86_64-unknown-intermezzos-gnu/libcore.rlib
        RUSTFLAGS="-L target/libcore/target/x86_64-unknown-intermezzos-gnu/release" cargo build --release --target x86_64-unknown-intermezzos-gnu.json
```

Whew! That's a bit of a mouthful. This is where it _might_ make some sense to
use some variables, at least. But let's not worry about this for now.

> But if you'd like to... [here's what it looks
> like](https://github.com/intermezzOS/kernel/blob/master/chapter_05/AlternateMakefile).
> You can assign variables with `=`, and then use them by putting their name in
> `$()`. Pretty slick! There's a balance here, and we could, in theory, go even
> further. This is a nice mix, I think, between being understandable and being
> maximally DRY.

We first write a rule to download our `libcore`. Next, we write a rule to
compile our `libcore.rlib`. Finally, we write a rule to build
`libintermezzos.a`. All of these commands are ones we used earlier to build
this stuff, so the details shouldn't be completely new, though organizing them
into these three rules is.

Try it out:

```bash
$ make cargo
git clone http://github.com/intermezzos/libcore target/libcore
Cloning into 'target/libcore'...
remote: Counting objects: 140, done.
remote: Compressing objects: 100% (8/8), done.
remote: Total 140 (delta 3), reused 0 (delta 0), pack-reused 132
Receiving objects: 100% (140/140), 362.70 KiB | 120.00 KiB/s, done.
Resolving deltas: 100% (52/52), done.
Checking connectivity... done.
cd target/libcore && git reset --hard 02e41cd5b925a1c878961042ecfb00470c68296b
HEAD is now at 02e41cd Reintroduce panic == abort
cp x86_64-unknown-intermezzos-gnu.json target/libcore
cd target/libcore && cargo build --release --features disable_float --target=x86_64-unknown-intermezzos-gnu.json
   Compiling core v0.0.0 (file:///home/steve/src/intermezzOS/kernel/chapter_05/target/libcore)
RUSTFLAGS="-L target/libcore/target/x86_64-unknown-intermezzos-gnu/release" cargo build --target x86_64-unknown-intermezzos-gnu.json
   Compiling intermezzos v0.1.0 (file:///home/steve/src/intermezzOS/kernel/chapter_05)
$
```

Success! It should all build properly. There's one more thing I'd like to note
about this makefile: in a strict sense, it will try and rebuild too much. But
watch what happens if we try to build a second time:

```bash
$ make cargo
cp x86_64-unknown-intermezzos-gnu.json target/libcore
cd target/libcore && cargo build --release --features disable_float --target=x86_64-unknown-intermezzos-gnu.json
RUSTFLAGS="-L target/libcore/target/x86_64-unknown-intermezzos-gnu/release" cargo build --target x86_64-unknown-intermezzos-gnu.json
$
```

We issued some commands, but didn't actually compile anything. With this
layout, we're letting Cargo worry if stuff needs to be rebuilt. This makes
our Makefile a bit easier to write, and also a bit more reliable. Cargo
knows what it needs to do, let's just trust it to do the right thing.

Now that we have it building, we need to modify the rule that builds the kernel
to include `libintermezzos.a`:

```make
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
cp x86_64-unknown-intermezzos-gnu.json target/libcore
cd target/libcore && cargo build --release --features disable_float --target=x86_64-unknown-intermezzos-gnu.json
RUSTFLAGS="-L target/libcore/target/x86_64-unknown-intermezzos-gnu/release" cargo build --release --target x86_64-unknown-intermezzos-gnu.json
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
Modfiy `src/asm/boot.asm`, removing all of the `long_mode_start` stuff,
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
#[no_mangle]
pub extern fn kmain() -> ! {
    kprintln!("Hello, world!");

    loop { }
}
```

But for now, kick back and enjoy what you've done. Congratulations!
