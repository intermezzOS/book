# Understanding text mode

We've called this a "VGA driver" so far, but it's a bit more specific than
that: VGA has both graphical and text modes. We're going to be doing text mode,
as it's simpler than graphics, and we need to get *something* going in order to
see output.

## Memory mapping

The first thing to understand about how VGA's text mode works is that it's
"memory mapped." This means that you interact with it by writing to a chunk
of memory.

We haven't talked too much about memory yet, and we'll talk about it much
more in the future; one of a kernel's many jobs is to manage memory. In
general, for the kind of hardware we're writing, memory is *linear*, that is,
the first memory address starts at 0, the next one at 1, and so on and so on.

> Like all things, this is fundamentally an abstraction: in the future, when
> we have programs running on our OS, they will think they're using linear
> memory even when they're not! That's getting a bit ahead of ourselves, though...

We can refer to a memory location by its particular number, and read values
from it, or store values in it. Its number is called its "address," and the
amount of memory we can give an address to is called "addressable memory."

How much is that? Well, it depends on the amount of RAM that's installed in
our computer. Eventually, our kernel will learn how to ask how much memory is
available, but for now, we're using so little memory that we're just going to
assume that it's all there and works okay. You have to walk before you can run!

Furthermore, memory addresses are usually written in *hexadecimal*. The usual
system of numbers humans used is "decimal", or "base 10." Hexadecimal is
"base 16." If you haven't worked with hexadecimal numbers before, you should
check out [Appendix B](../appendix/hexadecimal-numbers.md). If you don't want
to, you don't have to: just know that hexadecimal numbers have the letters
`a` through `f` in them, and you should be able to follow along at first.
You'll eventually want to come back to this and learn it, though, as we'll be
using them more and more as time goes on.

So, applying this to VGA text mode: there's a block of memory located at the
address `0xb8000`, and it consists of four thousand bytes. In our case, a
byte is eight bits, each consisting of a zero or a one. Why is it at this
address? Because that's what the specification says. I'm sure there's a
justification, but it doesn't really matter for our purposes: that's what it
says, so that's what we do.

With this understanding, this line of code on the previous page may make some sense:

```rust
let slice = unsafe { core::slice::from_raw_parts_mut(0xb8000 as *mut u8, 4000) };
```

This creates a `&mut [u8]`, a mutable "slice" of bytes. `from_raw_parts_mut`
takes a `*mut u8`, a "raw pointer", and a length, and creates a slice of that
length starting from that pointer. To make a raw pointer, we can write out
the memory address, and then cast with `as`. The address starts with `0x`
because it's written in hexadecimal.

Finally, this is *very* unsafe, in a Rust sense: we're creating a slice to an
arbitrary spot in memory, and are gonna start writing values to it. We know
that this is okay, because we're a kernel and we know the specification. Rust
doesn't know anything about VGA, and so can't check that this code is
correct. We can, and that's exactly what `unsafe` is there for.

## Writing to the map

Now that we have a slice, we can use `[]` to index it, and read or write from
any index. The next bit of code looks like this:

```rust
slice[0] = b'h';
slice[1] = 0x02;
```

It repeats in this pattern over and over, in twos.

We're writing things to the first and second locations in our slice. But why do
we write these specific things? Well, the first one is called the *character byte*,
and the second is called the *attribute byte*.

### The character byte

The first byte is called the "character byte" because well, it's a character!
More specifically, you can put ASCII characters in here. But more
importantly, you don't write the character itself, you write *its numeric
value*. That's what the `b''` is doing; instead of an `'h'`, which would be a
`char` in Rust, and therefore be four bytes (thanks to Unicode), we want the
ASCII version. Rust provides the `b''` construct to make getting this value
easy; we can write `b'h'`, but actually get a `u8` instead of a `char`.

### The attribute byte

The second byte is the "attribute" byte, and it sets two different things:
the foreground color, and the background color. Here's the list of possible
colors and their numeric values:

| name | value |
|------|-------|
| Black | `0x0` |
| Blue | `0x1` |
| Green | `0x2` |
| Cyan | `0x3` |
| Red | `0x4` |
| Magenta | `0x5` |
| Brown | `0x6` |
| Gray | `0x7` |
| DarkGray | `0x8` |
| BrightBlue | `0x9` |
| BrightGreen | `0xA` |
| BrightCyan | `0xB` |
| BrightRed | `0xC` |
| BrightMagenta | `0xD` |
| Yellow | `0xE` |
| White | `0xF` |

So, these are individual colors, but how do you choose both? Let's look closely
at that line again:

```rust
slice[1] = 0x02;
```

See how there's both a `0` and a `2`? The first value is `0`, the background
color, which is black. The second is `2`, the foreground color, which is
green. This is an example of why hexadecimal is useful; we can look at `0x02`
and say "oh, black and green" because of the `0` and the `2`.

### Conclusion

To get a feeling for all of this, try to change the foreground colors,
background colors, and letters. Write some letters in different colors than
other letters. It's up to you! Once you feel comfortable with this, you can
move on to the next section. Even though you *can* memorize these numbers,
you don't have to: we'll create a nicer implementation that makes this much
more readable.
