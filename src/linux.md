# Linux

Here are the tools we’re going to need:

* `nasm`
* `ld`
* `grub-mkrescue` + `xorriso`
* `qemu`

How to install the tools depends on your distribution.

On Debian you can install them with

```bash
$ sudo apt-get install nasm xorriso qemu build-essential
```

On Arch Linux you can install them with

```bash
$ sudo pacman -S binutils grub libisoburn nasm qemu
```
