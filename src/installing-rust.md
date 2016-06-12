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
$ rustup update nightly-2016-05-26
```

This installs the version of nightly Rust for May 26th, 2016. We'll try to keep
the book current and upgrade Rust periodically, so if you take a break and come
back to things, check back with this chapter to see if you need to upgrade.

Then, execute this:

```bash
$ rustup override add nightly-2016-05-26.
```

This sets up `rustup` to switch to the Rust we need whenever we're in this
directory. Nice and easy. We can't get the version wrong; `rustup` handles it
for us.
