# Installing Rust

First, you need to get a copy of Rust! There's one catch though: you'll need to
get _exactly_ the correct version of Rust. Unfortunately, for OS development,
we need to take advantage of some cutting-edge features that aren't yet stable.

Luckily, the Rust project has a tool that makes it easy to switch between Rust
versions: `rustup`. You can get it from the [install
page](http://rust-lang.org/install.html) of the Rust website.

By default, `rustup` uses stable Rust. So let's tell it to install nightly:

```bash
$ rustup update nightly
```

This installs the current version of nightly Rust. We run all of the examples
in this book under continuous integration, so we should know if something
changes in nightly Rust and breaks. But please [file bugs] if something doesn't
work.

[file bugs]: https://github.com/intermezzOS/book/issues/new

Because nightly Rust includes unstable features, you shouldn't use it unless
you really need to, which is why `rustup` allows you to override the default
version only when you're in a particular directory. We don't have a directory
for our project yet, so let's create one:

```bash
$ mkdir intermezzOS
$ cd intermezzOS
```

A fun way to follow along is to pick a different name for your kernel, and
then change it as we go. Call your kernel whatever you want. intermezzOS was
almost called ‘Nucleus’, until I found out that there’s already a kernel with
that name that’s installed on billions of embedded devices. Whoops!

Inside your project directory, set up the override:

```bash
$ rustup override add nightly
```

Nice and easy. We can't get the version wrong; `rustup` handles it for us.
