# Linux

Here are the tools we’re going to need:

* Rust
* `nasm`
* `ld`
* `grub-mkrescue` + `xorriso`
* `qemu`

To install Rust, check out [rustup](https://www.rustup.rs/).

Once you have installed Rust via `rustup`, you can switch to the nightly version we will
be using for intermezzOS by typing

```bash
rustup default nightly-2016-04-12
```

How to install the other tools depends on your distribution.

On Debian you can install them with

```bash
$ sudo apt-get install nasm xorriso qemu build-essential
```

On Arch Linux you can install them with

```bash
$ sudo pacman -S binutils grub libisoburn nasm qemu
```
