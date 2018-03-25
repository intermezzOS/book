# Jumping headlong into long mode

We are so close to Rust! Just a little bit of assembly code needed.

Our last task is to update several special registers called 'segment
registers'. Again, we're not using segmentation, but things won't work
unless we set them properly. Once we do, we'll be out of the compatibility
mode and into long mode for real.

Updating the first three registers is easy:

```x86asm
; update selectors
mov ax, gdt64.data
mov ss, ax
mov ds, ax
mov es, ax
```

Here's a short rundown of these registers:

* `ax`: This isn't a segment register. It's a sixteen-bit register. Remember
  'eax' from our loop accumulator? The 'e' was for 'extended', and it's the
  thirty-two bit version of the `ax` register. The segment registers are
  sixteen bit values, so we start off by putting the data part of our GDT
  into it, to load into all of the segment registers.
* `ss`: The 'stack segment' register. We don't even have a stack yet, that's
  how little we're using this. Still needs to be set.
* `ds`: the 'data segment' register. This points to the data segment of our
  GDT, which is conveniently what we loaded into `ax`.
* `es`: an 'extra segment' register. Not used, still needs to be set.

There's one more register which needs to be updated, however: the code segment
register, `cs`. Should be an easy `mov cs, ax`, right? Wrong! It's not that easy.
Unfortunately, we can't modify the code segment register ourselves, or bad
things can happen. But we need to change it. So what do we do?

The way to change `cs` is to execute what's called a 'far jump'. Have you heard
of goto? A jump is just like that; we used one to do our little loop when
setting up paging. A 'far jump' is a jump instruction that goes really far.
That's a little bit simplistic, but the full technical details involve stuff
about memory segmentation, which again, we're not using, so going into them
doesn't matter.

Here's the line to make our far jump:

```x86asm
; jump to long mode!
jmp gdt64.code:long_mode_start
```

Previously, when we used `jne` to set up paging, we passed it a label to jump
to. We're doing the same here, but this time, the label is `long_mode_start`.
We'll define that in a minute. Before we do, we should talk about the other
part of this instruction: `gdt64.code:`. This is another label, the one to
the code entry of our GDT. This `foo:bar` syntax is what makes this a long
jump; we're also providing our GDT entry when we jump. When we execute this,
it will then update the code selector register with our entry in the GDT!

I've always loved this part of the boot process. It's very visual for me;
your OS makes a long leap of faith, and comes out the other side realizing that
it has more abilities than it thought! A classic tale of bravery.

But where is this `long_mode_start` that we're jumping to? Why, defined at
the bottom of our file, of course! Put this at the end of `boot.asm`:

```x86asm
section .text
bits 64
long_mode_start:

    hlt
```

A new section! It's another `text` section, like the rest of our code. But
there's a new `bits 64` declaration: we're in honest-to-goodness 64-bit mode
now!

Finally, we have our `long_mode_start` label, and then a humble `hlt`
instruction to stop execution.

With this set up, we are now officially in long mode! Congrats! Let's do
a small thing to prove it. Modify this code to look like this:

```x86asm
long_mode_start:

    mov rax, 0x2f592f412f4b2f4f
    mov qword [0xb8000], rax

    hlt
```

We have a new fancy register, `rax`! Like `eax` is a 32-bit version of `ax`,
`rax` is a 64-bit version of `eax`. The 'e' in `eax` stood for 'extended', the
'r' in `rax` stands for... register. Can't make this stuff up.

Anyway, we put a mystery sixty-four-bit value into `rax`, and then write it
into `0xb8000`. If you recall from earlier, that's the upper-left part of the
screen. The `qword` bit stands for 'quad-word', aka, 64-bit. A word is 16 bits,
a double word is 32 bits, so a quad word is 64 bits.

What does it say? Well, you'll have to run it and find out. 😊

Our next step is going to be a big one: moving to writing Rust code! I hope
you've enjoyed this tour of assembly and legacy computer junk. You've made it
through the toughest bits: getting started is the hardest part.
