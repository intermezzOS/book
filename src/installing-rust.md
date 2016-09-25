# Installing Rust

First, you need to get a copy of Rust! There's one catch though: you'll need to
get _exactly_ the correct version of Rust. Unfortunately, for OS development,
we need to take advantage of some cutting-edge features that aren't yet stable.
So in order for this to work, you have to be using the exact correct Rust. Don't
worry though, it's easy to do. Put this in your terminal:

```bash
$ curl https://sh.rustup.rs -sSf | sh
```

This will install `rustup`. At the time of this writing, `rustup` is in beta,
but it will be the de-facto way to get Rust from the Rust team. It also makes
it very easy to switch between different versions of Rust, and install
multiple copies of Rust, both of which are features that are of use to us. If
you do other Rust work, you won't want to be stuck with the version we use here!

To get the Rust we need, first type this:

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
