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
in this book under continunous integration, so we should know if something
changes in nightly Rust and breaks. But please [file bugs] if something doesn't
work.

[file bugs]: https://github.com/intermezzOS/book/issues/new

Then, execute this:

```bash
$ rustup override add nightly
```

This sets up `rustup` to switch to the Rust we need whenever we're in this
directory. Nice and easy. We can't get the version wrong; `rustup` handles it
for us.
