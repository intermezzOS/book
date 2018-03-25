# Automation with Make

Typing all of these commands out every time we want to build the project is
tiring and error-prone. It’s nice to be able to have a single command that
builds our entire project. To do this, we’ll use `make`. Make is a classic
bit of software that’s used for this purpose. At its core, `make` is fairly
simple:

* You create a file called `Makefile`.
* In this file, you define **rules**. Rules are composed of three things:
  **targets**, **prerequisites**, and **commands**.
* Targets describe what you are trying to build.
* Targets can depend on other targets being built before they can be built.
  These are called ‘prerequisites’.
* Commands describe what it takes to actually build the target.

Let’s start off with a very straightforward rule. Specifically, the first step
that we did was to build the Multiboot header by running `nasm`. Let’s build a
`Makefile` that does this. Open a file called `Makefile` and put this in it:

```makefile
multiboot_header.o: multiboot_header.asm
        nasm -f elf64 multiboot_header.asm
```

It’s _very_ important that that `nasm` line uses a tab to indent. It can’t be
spaces. It has to be a tab. Yay legacy software!

Let’s try to run it before we talk about the details:

```bash
$ make
nasm -f elf64 multiboot_header.asm
$
```

If you see this output, success! Let’s talk about this syntax:

```text
target: prerequisites
        command
```

The bit before the colon is called a ‘target’. That’s the thing we’re trying to
build. In this case, we want to create the `multiboot_header.o` file, so we name
our target after that.

After the colon comes the ‘prerequisites’. This is a list of other targets that must
be built for this target to be built. In this case, building `multiboot_header.o`
requires that we have a `multiboot_header.asm`. We have no rule describing how
to build this file but it existing is enough to satisfy the dependency.

Finally, on the next line, and indented by a tab, we have a ‘command’. This is the
shell command that you need to build the target.

Building `boot.o` is similar:

```makefile
multiboot_header.o: multiboot_header.asm
        nasm -f elf64 multiboot_header.asm

boot.o: boot.asm
        nasm -f elf64 boot.asm
```

Let’s try to build it:

```bash
$ make
make: ‘multiboot_header.o’ is up to date.
$
```

Wait a minute, what? There’s two things going on here. The first is that `make` will build
the first target that you list by default. So a simple `make` will not build `boot.o`. To
build it, we can pass `make` the target name:

```bash
$ make boot.o
nasm -f elf64 boot.asm
```

Okay, so that worked. But what about this ‘is up to date’ bit?

By default, `make` will keep track of the last time you built a particular
target, and check the prerequisites’ last-modified-time against that time. If
the prerequisites haven’t been updated since the target was last built, then it
won’t re-execute the build command. This is a really powerful feature,
especially as we grow. You don’t want to force the entire project to re-build
just because you edited one file; it’s nicer to only re-build the bits that
interact with it directly. A lot of the skill of `make` is defining the right
targets to make this work out nicely.

It would be nice if we could build both things with one command, but as it
turns out, our next target, `kernel.bin`, relies on both of these `.o` files,
so let’s write it first:

```makefile
multiboot_header.o: multiboot_header.asm
        nasm -f elf64 multiboot_header.asm

boot.o: boot.asm
        nasm -f elf64 boot.asm

kernel.bin: multiboot_header.o boot.o linker.ld
        ld -n -o kernel.bin -T linker.ld multiboot_header.o boot.o
```

Let’s try building it:

```bash
$ make kernel.bin
ld -n -o kernel.bin -T linker.ld multiboot_header.o boot.o
```

Great! The `kernel.bin` target depends on `multiboot_header.o`, `boot.o`, and `linker.ld`. The
first two are the previous targets we defined, and `linker.ld` is a file on its own.

Let’s make `make` build the whole thing by default:

```makefile
default: kernel.bin

multiboot_header.o: multiboot_header.asm
        nasm -f elf64 multiboot_header.asm

boot.o: boot.asm
        nasm -f elf64 boot.asm

kernel.bin: multiboot_header.o boot.o linker.ld
        ld -n -o kernel.bin -T linker.ld multiboot_header.o boot.o
```

We can name targets whatever we want. In this case, `default` is a good
convention for the first rule, as it’s the default target. It relies on
the `kernel.bin` target, which means that we’ll build it, and as we previously
discussed, `kernel.bin` will build our two `.o`s.

Let’s try it out:

```bash
$ make
make: Nothing to be done for ‘default’.
```

We haven’t edited our files, so everything is built. Let’s modify one. Open up
`multiboot_header.asm` in your editor, save it, and then run `make`:

```bash
$ make
nasm -f elf64 multiboot_header.asm
ld -n -o kernel.bin -T linker.ld multiboot_header.o boot.o
```

It re-built `multiboot_header.o`, and then `kernel.bin`. But it didn’t rebuild
`boot.o`, as we didn’t modify it at all.

Let’s add a new rule to build our iso. Rather than show the entire `Makefile`, I’m
going to start showing you what’s changed. First, we have to update our `default`
target, and then we have to write the new one:

```makefile
default: os.iso

os.iso: kernel.bin grub.cfg
        mkdir -p isofiles/boot/grub
        cp grub.cfg isofiles/boot/grub
        cp kernel.bin isofiles/boot/
        grub-mkrescue -o os.iso isofiles
```

This is our first multi-command rule. `make` will execute all of the commands
that you list. In this case, to build the ISO, we need to create our `isofiles`
directory, and then copy `grub.cfg` and `kernel.bin` into the right place
inside of it. Finally, `grub-mkrescue` builds the ISO from that directory.

This rule assumes that `grub.cfg` is at our top-level directory, but it’s
currently in `isofiles/boot/grub` already. So let’s copy it out:

```bash
$ cp isofiles/boot/grub/grub.cfg .
```

And now we can build:

```bash
$ make
mkdir -p isofiles/boot/grub
cp grub.cfg isofiles/boot/grub
cp kernel.bin isofiles/boot/
grub-mkrescue -o os.iso isofiles
```

Sometimes, it’s nice to add targets which describe a semantic. In this case, building
the `os.iso` target is the same as building the project. So let’s say so:

```makefile
default: build

build: os.iso
```

The default action is to build the project, and to build the project, we need to build
`os.iso`. But what about running it? Let’s add a rule for that:

```makefile
default: run

run: os.iso
        qemu-system-x86_64 -cdrom os.iso
```

You can choose the default here: do you want the default to be build, or run? Here’s what
each looks like:

```bash
$ make     # build is the default
$ make run
```

or

```bash
$ make       # run is the default
$ make build
```

I prefer to make `run` the default.

Finally, there’s another useful common rule: `clean`. The `clean` rule should remove all
of the generated files, and allow us to do a full re-build. As such it’s a bunch of `rm`
statements:

```makefile
clean:
        rm -f multiboot_header.o
        rm -f boot.o
        rm -f kernel.bin
        rm -rf isofiles
        rm -f os.iso
```

Now there's just one more wrinkle. We have four targets that aren't really files
on disk, they are just actions: `default`, `build`, `run` and `clean`. Remember
we said earlier that `make` decides whether or not to execute a command by
comparing the last time a target was built with the last-modified-time of its
prerequisites? Well, it determines the last time a target was built by looking
at the last-modified-time of the target file. If the target file doesn't exist,
then it's definitely out-of-date so the command will be run.

But what if we accidentally create a file called `clean`? It doesn't have any
prerequisites so it will always be up-to-date and the commands will never be
run! We need a way to tell `make` that this is a special target, it isn't really
a file on disk, it's an action that should always be executed. We can do this
with a magic built-in target called `.PHONY`:

```makefile
.PHONY: default build run clean
```

Here’s our final `Makefile`:

```makefile
default: run

.PHONY: default build run clean

multiboot_header.o: multiboot_header.asm
        nasm -f elf64 multiboot_header.asm

boot.o: boot.asm
        nasm -f elf64 boot.asm

kernel.bin: multiboot_header.o boot.o linker.ld
        ld -n -o kernel.bin -T linker.ld multiboot_header.o boot.o

os.iso: kernel.bin grub.cfg
        mkdir -p isofiles/boot/grub
        cp grub.cfg isofiles/boot/grub
        cp kernel.bin isofiles/boot/
        grub-mkrescue -o os.iso isofiles

build: os.iso

run: os.iso
        qemu-system-x86_64 -cdrom os.iso

clean:
        rm -f multiboot_header.o
        rm -f boot.o
        rm -f kernel.bin
        rm -rf isofiles
        rm -f os.iso
```

You'll notice that there is a fair amount of repetition here. At first, that's
pretty okay: make can be a bit hard to understand, and while it has features
that let you de-duplicate things, they can also get unreadable really fast.

## Creating a build subdirectory

Here's one example of a tweak we can do: `nasm` supports a `-o` flag, which
controls the name of the output file. We can use this to build _everything_ in
a `build` subdirectory. This is nice for a number of reasons, but one of the
simplest is that all of our generated files will go in a single directory,
which means that it’s much easier to keep track of them: they’ll all be in one
place.

Let’s make some changes: More specifically, three of them:

```makefile
build/multiboot_header.o: multiboot_header.asm
        mkdir -p build
        nasm -f elf64 multiboot_header.asm -o build/multiboot_header.o
```

The first one is the name of the rule. We have to add a `build/` in front of
the filename. This is because we’re going to be putting this file in that
directory now.

Second, we added another line: `mkdir`. We used `-p` to make directories
before, but in this case, the purpose of the flag is to not throw an error
if the directory already exists. We need to try to make this directory
when we build so that we can put our `.o` file in it!

Finally, we add the `-o` flag to `nasm`. This will create our output file in
that `build` directory, rather than in the current one.

With that, we’re ready to modify `boot.o` as well:

```makefile
build/boot.o: boot.asm
        mkdir -p build
        nasm -f elf64 boot.asm -o build/boot.o
```

These changes are the same, just with `boot` instead of `multiboot_header`.

Next up: `kernel.bin`:

```makefile
build/kernel.bin: build/multiboot_header.o build/boot.o linker.ld
        ld -n -o build/kernel.bin -T linker.ld build/multiboot_header.o build/boot.o
```

We add `build` in no fewer than _six_ places. Whew! At least it’s
straightforward.

```makefile
build/os.iso: build/kernel.bin grub.cfg
        mkdir -p build/isofiles/boot/grub
        cp grub.cfg build/isofiles/boot/grub
        cp build/kernel.bin build/isofiles/boot/
        grub-mkrescue -o build/os.iso build/isofiles
```

Seeing a pattern yet? More prefixing.

```makefile
run: build/os.iso
        qemu-system-x86_64 -cdrom build/os.iso
```

... and here as well.

```makefile
clean:
        rm -rf build
```

Now some payoff! To get rid of our generated files, all we have to do is `rm`
our `build` directory. Much easier.

Here’s our final version:

```makefile
default: run

.PHONY: default build run clean

build/multiboot_header.o: multiboot_header.asm
        mkdir -p build
        nasm -f elf64 multiboot_header.asm -o build/multiboot_header.o

build/boot.o: boot.asm
        mkdir -p build
        nasm -f elf64 boot.asm -o build/boot.o

build/kernel.bin: build/multiboot_header.o build/boot.o linker.ld
        ld -n -o build/kernel.bin -T linker.ld build/multiboot_header.o build/boot.o

build/os.iso: build/kernel.bin grub.cfg
        mkdir -p build/isofiles/boot/grub
        cp grub.cfg build/isofiles/boot/grub
        cp build/kernel.bin build/isofiles/boot/
        grub-mkrescue -o build/os.iso build/isofiles

run: build/os.iso
        qemu-system-x86_64 -cdrom build/os.iso

build: build/os.iso

clean:
        rm -rf build
```

We can go further, and eventually, we will. But this is good enough for now.
Like I said, there’s a fine balance between keeping it [DRY][] and making it
non-understandable.

[DRY]: https://en.wikipedia.org/wiki/Dont_repeat_yourself

Luckily, we’ll only be using Make for these assembly files. Rust has its own
build tool, Cargo, that we’ll integrate with Make. It’s a lot easier to use.
