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
$ sudo pacman -S --needed binutils grub mtools libisoburn nasm qemu
```

And on Fedora with

```bash
$ sudo dnf install nasm xorriso qemu
```

Note that if your Fedora is up-to-date enough you will need to call `grub2-mkrescue` command instead of `grub-mkrescue`.
