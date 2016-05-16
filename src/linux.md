# Linux

Here are the tools we’re going to need:

* Rust
* `nasm`
* `ld`
* `grub-mkrescue` + `xorriso`
* `qemu`

To install Rust, check out [rustup](https://www.rustup.rs/).

During the installation, you can select "Customize installation" to change
the default toolchain to "nightly" and optionally allow the script to modify
your PATH on your behalf. Then proceed with the installation.

If you already installed `rust` with the stable toolchain, you can switch to the nightly by typing `rustup default nightly` in a shell.

How to install the other tools depends on your distribution.

On Debian you can install them with

```bash
$ sudo apt-get install nasm xorriso qemu build-essential
```

On Arch Linux you can install them with

```bash
$ sudo pacman -S binutils grub libisoburn nasm qemu
```
