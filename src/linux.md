# Linux

Here are the tools we’re going to need:

* Rust
* `nasm`
* `ld`
* `grub-mkrescue` + `xorriso`
* `qemu`

To install Rust, check out [multirust](https://github.com/brson/multirust).

Once you have it installed, grab a nightly build:

```bash
$ multirust update PUT NIGHTLY HERE
$ multirust default PUT NIGHTLY HERE
```

TODO: https://github.com/intermezzOS/book/issues/26

How to install the other tools, depends on your distribution.

On Debian you can install them with

```bash
$ sudo apt-get install nasm xorriso qemu build-essential
```

On Arch Linux you can install them with

```bash
$ sudo pacman -S binutils grub libisoburn nasm qemu
```
