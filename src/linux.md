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

To install the other tools, on Debian:

```bash
$ sudo apt-get install nasm xorriso qemu build-essentials
```
