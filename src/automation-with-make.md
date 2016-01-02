# Automation with Make

(Author’s note: I wrote this post sort of backwards-first, but I’m done
writing for the night, so I’m pushing this up as an extra-rough draft.

I will explain all of this soon, but until I write it down, you can put
all of this in a file called `Makefile`.)

```make
default: run

.PHONY: clean

multiboot_header.o: multiboot_header.asm
        nasm -f elf64 multiboot_header.asm

boot.o: boot.asm
        nasm -f elf64 boot.asm

kernel.bin: multiboot_header.o boot.o linker.ld
        ld -n -o kernel.bin -T linker.ld multiboot_header.o boot.o

isofiles: kernel.bin grub.cfg
        mkdir -p isofiles/boot/grub
        cp grub.cfg isofiles/boot/grub
        cp kernel.bin isofiles/boot/

os.iso: isofiles
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

```make
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

```make
build/boot.o: boot.asm
        mkdir -p build
        nasm -f elf64 boot.asm -o build/boot.o
```

These changes are the same, just with `boot` instead of `multiboot_header`.

Next up: `kernel.bin`:

```make
build/kernel.bin: build/multiboot_header.o build/boot.o linker.ld
        ld -n -o build/kernel.bin -T linker.ld build/multiboot_header.o build/boot.o
```

We append `build` in no fewer than _six_ places. Whew! At least it’s
straightforward.

```make
build/isofiles: build/kernel.bin grub.cfg
        mkdir -p build/isofiles/boot/grub
        cp grub.cfg build/isofiles/boot/grub
        cp build/kernel.bin build/isofiles/boot/
```

In a similar fashion, we prefix all the things with `build`.

```make
build/os.iso: build/isofiles
        grub-mkrescue -o build/os.iso build/isofiles
```

Seeing a pattern yet? More prefixing.

```make
run: build/os.iso
        qemu-system-x86_64 -cdrom build/os.iso
```

... and here as well.

```make
clean: 
        rm -rf build
```

Now some payoff! To get rid of our generated files, all we have to do is `rm`
our `build` directory. Much easier.

Here’s our final version:

```make
default: run

.PHONY: clean

build/multiboot_header.o: multiboot_header.asm
        mkdir -p build
        nasm -f elf64 multiboot_header.asm -o build/multiboot_header.o

build/boot.o: boot.asm
        mkdir -p build
        nasm -f elf64 boot.asm -o build/boot.o

build/kernel.bin: build/multiboot_header.o build/boot.o linker.ld
        ld -n -o build/kernel.bin -T linker.ld build/multiboot_header.o build/boot.o

build/isofiles: build/kernel.bin grub.cfg
        mkdir -p build/isofiles/boot/grub
        cp grub.cfg build/isofiles/boot/grub
        cp build/kernel.bin build/isofiles/boot/

build/os.iso: build/isofiles
        grub-mkrescue -o build/os.iso build/isofiles

run: build/os.iso
        qemu-system-x86_64 -cdrom build/os.iso

clean: 
        rm -rf build
```

We can go farther, and eventually, we will. But this is good enough for now.
Like I said, there’s a fine balance between keeping it DRY and making it
non-understandable.

Luckily, we’ll only be using Make for these assembly files. Rust has its own
build tool, Cargo, that we’ll integrate with Make. It’s a lot easier to use.
