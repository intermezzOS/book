# Appendix A: Troubleshooting

In this appendix, we will cover common errors and their solutions for
various chapters of the book.

## Chapter 3

Here are various solutions to issues you may run into in Chapter 3:

### Error: no multiboot header found

When booting up your kernel, QEMU may print out a message like this:

```text
error: no multiboot header found
error: you need to load the kernel first
```

This can happen for a number of reasons, but is often caused by typo-ing
something. Double check your code against the examples and make sure that
they’re _identical_, especially things like magic numbers. They’re easy to
mis-type.

### Could not read from CDROM (code 0009)

On a system that uses EFI to boot, you may see an error like this:

```text
$ qemu-system-x86_64 -cdrom os.iso
Could not read from CDROM (code 0009)
```

The solution may be to install the `grub-pc-bin` package:

```bash
$ sudo apt-get install grub-pc-bin
```

### xorriso : FAILURE : Cannot find path ‘/efi.img’ in loaded ISO image

When building the ISO, you may see a message like this:

```text
xorriso : FAILURE : Cannot find path ‘/efi.img’ in loaded ISO image
```

The solution may be to install the `mtools` package:

```bash
$ sudo apt-get install mtools
```

### Could not initialize SDL(No available video device) - exiting

When booting your kernel in QEMU, you may see an error like this:

```text
Could not initialize SDL(No available video device) - exiting
```

You can pass an extra flag to QEMU to not use SDL, `-curses`:

```bash
$ qemu-system-x86_64 -curses -cdrom os.iso
```

Or, try installing SDL and its development headers:

```bash
$ sudo apt-get install libsdl2-dev
```
