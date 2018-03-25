# intermezzOS: The Book

## Prerequisites

This project is built using [Rust], so you'll need to
install Rust in order to build the book.

[`rustup`] is the recommended way to install Rust.

You also can download Rust [here][1].

## Up and Running

```
$ git clone git@github.com:intermezzOS/book.git intermezzOS/book
$ cd intermezzOS/book
$ cargo install mdbook
```

Then, inside the `first-edition` or `second-edition` directories, run this:

```
$ mdbook build
```

The [`mdbook`] crate builds from `markdown` files in `/src`,
creating `html` files in a `/book` directory.

Open `index.html` in your browser to view the built book.

[`mdbook`]: https://github.com/azerupi/mdBook
[1]: https://www.rust-lang.org/downloads.html
[`rustup`]: https://www.rustup.rs
[Rust]: http://www.rust-lang.org
