# Appendix A: target specifications

In Chapter 2, we created `intermezzos.json`, a "target specification."
Here's the reasons for setting each thing:

```json
  "llvm-target": "x86_64-unknown-none",
```

This is called a "target triple", and is fed to [LLVM](http://llvm.org/), the
project that `rustc` uses to generate the final binary code. It's called a "triple"
becuase it has three parts: the CPU, the vendor, and the OS. So for this target,
we choose the x86_64 CPU, an 'unknown' vendor since we're not a big company or
something, and 'none' for the OS, since our OS does not rely on an OS.

```json
  "data-layout": "e-m:e-i64:64-f80:128-n8:16:32:64-S128",
```

This is another LLVM thing, you can find the documentation
[here](http://llvm.org/docs/LangRef.html#data-layout). Honestly, it's not
very interesting; feel free to read those docs if you want to learn more.

```json
  "arch": "x86_64",
```

This also sets our CPU architecture; as we said in the target above, it's `x86_64`.

```json
  "target-endian": "little",
```

"Endian-ness" is a property of how binary numbers are transmitted; there are three
forms: "big endian," "little endian," and "network endian", which is a synonym for
"big endian." This is because most network protocols choose big endian.

Intel uses little endian for their processors, however, and so we set that here.

```json
  "target-pointer-width": "64",
```

We're building a 64-bit OS, so our pointers are 64 bits wide. If you don't know what
a pointer is, don't worry about it yet.

```json
  "target-c-int-width": "32",
```

We're not using C, so this doesn't matter, but if we were, we'd make integers
32 bits. This is common on the x86_64 platform.

```json
  "os": "none",
```

We don't have an OS! We're building one!

```json
  "linker": "rust-lld",
  "linker-flavor": "ld.lld",
```

We'll be using [LLD](https://lld.llvm.org/) for linking; this linker is
provided by the LLVM project, and automatically distributed with Rust.

```json
  "executables": true,
```

Are executables allowed on this target, or only libraries? That might
sound silly, but iOS, for example, won't let you create executables.

```json
  "features": "-mmx,-sse,+soft-float",
```

These flags control the kind of code that Rust generates. For reasons we
won't get into right now, many kernels don't use floating point numbers or
[SIMD registers](https://en.wikipedia.org/wiki/SIMD) in the kernel, so we
want to turn those options off. (MMX is a similar feature to SIMD). "soft
float" means to not use actual floating point hardware instructions, but to
emulate them in software. We won't be using floating point numbers at all,
directly, but just in case, we want to make sure that we're not going to be
using the hardware for it. We'll talk more about this later.

```json
  "disable-redzone": true,
```

This is a very tricky one! The x86_64 "calling convention", that is, the way
that assembly code for functions is called, allows for a thing called the
"red zone." We *do not want* this for a kernel. Forgetting this setting runs
into all kinds of really strange looking bugs.

```json
  "panic-strategy": "abort"
```

Finally, we don't want to use Rust's panics, so by setting them to abort
instead of unwind, we don't generate code to handle panics.
