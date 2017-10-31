# Setting up a GDT

We’re so close! We’re currently in long mode, but not ‘real’ long mode. We need
to go from this ‘compatibility mode’ to honest-to-goodness long mode. To do
this, we need to set up a ‘global descriptor table’.

This table, also known as a GDT, is kind of vestigial. The GDT is used for a
style of memory handling called ‘segmentation’, which is in contrast to the
paging model that we just set up. Even though we’re not using segmentation,
however, we’re still required to have a valid GDT. Such is life.

So let’s set up a minimal GDT. Our GDT will have three entries:

* a ‘zero entry’
* a ‘code segment’
* a ‘data segment’

If we were going to be using the GDT for real stuff, it could have a number
of code and data segment entries. But we need at least one of each to have a
minimum viable table, so let’s get to it!

## The Zero entry

The first entry in the GDT is special: it needs to be a zero value. Add this
to the bottom of `boot.asm`:

```x86asm
section .rodata
gdt64:
    dq 0
```

We have a new section: `rodata`. This stands for ‘read only data’, and since
we’re not going to modify our GDT, having it be read-only is a good idea.

Next, we have a label: `gdt64`. We’ll use this label later, to tell the hardware
where our GDT is located.

Finally, `dq 0`. This is ‘define quad-word’, in other words, a 64-bit value.
Given that it’s a zero entry, it shouldn’t be too surprising that the value of
this entry is zero!

That’s all there is to it.

## Setting up a code segment

Next, we need a code segment. Add this below the `dq 0`:

```x86asm
.code: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41) | (1<<43) | (1<<53)
```

Let's talk about the `dq` line first. If you recall from the last section,
`1<<44` means ‘left shift one 44 places’, which sets the 44th bit. But what
about `|`? This means `or`. So, if we `or` a bunch of these values together,
we’ll end up with a value that has the 44th, 47th, 41st, 43rd, and 53rd bit
set.

Why `|` and not `or`, like before? Well, here, we’re not running assembly
instructions: we’re defining some data. So there’s no instruction to execute, so
the language used is a bit different.

Finally, why these bits? Well, as we’ve seen with other table entries, each bit
has a meaning. Here’s a summary:

* 44: ‘descriptor type’: This has to be `1` for code and data segments
* 47: ‘present’: This is set to `1` if the entry is valid
* 41: ‘read/write’: If this is a code segment, `1` means that it’s readable
* 43: ‘executable’: Set to `1` for code segments
* 53: ‘64-bit’: if this is a 64-bit GDT, this should be set

That’s all we need for a valid code segment!

Oh, but let's not forget about the other line:

```x86asm
.code: equ $ - gdt64
```

What's up with this? So, in a bit, we'll need to reference this entry somehow.
But we don't reference the entry by its address, we reference it by an offset.
If we needed just an address, we could use `code:`. But we can't, so we need
more. Also, note that period at the start, it's `.code:`. This tells the
assembler to scope this label under the last label that appeared, so we'll
say `gdt64.code` rather than just `code`. Some nice encapsulation.

So that's what's up with the label, but we still have this `equ $ - gdt64` bit.
`$` is the current position. So we're subtracting the address of `gdt64` from
the current position. Conveniently, that's the offset number we need for later:
how far is this segment past the start of the GDT. The `equ` sets the address
for the label; in other words, this line is saying "set the `.code` label's
value to the current address minus the address of `gdt64`". Got it?

## Setting up a data segment

Below the code segment, add this for a data segment:

```x86asm
.data: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41)
```

We need less bits set for a data segment. But they’re ones we covered before.
The only difference is bit 41; for data segments, a `1` means that it’s
writable.

We also use the same trick again with the labels, calculating the offset with
`equ`.

## Putting it all together

Here’s our whole GDT:

```x86asm
section .rodata
gdt64:
    dq 0
.code: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41) | (1<<43) | (1<<53)
.data: equ $ - gdt64
    dq (1<<44) | (1<<47) | (1<<41)
```

We’re so close! Now, to tell the hardware about our GDT. There’s a special
assembly instruction for this: `lgdt`. But it doesn’t take the GDT itself; it
takes a special structure: two bytes for the length, and eight bytes for the
address. So we have to set _that_ up.

Below these `dq`s, add this:

```x86asm
.pointer:
    dw .pointer - gdt64 - 1
    dq gdt64
```

To calculate the length, we take the value of this new label, `pointer`, and
subtract the value of `gdt64`, and then subtract one more. We could calculate
this length manually, but if we do it this way, if we add another GDT entry for
some reason, it will automatically correct itself, which is nice.

The `dq` here has the address of our table. Straightforward.

## Load the GDT

So! We’re finally ready to tell the hardware about our GDT. Add this line after
all of the paging stuff we did in the last chapter:

```x86asm
    lgdt [gdt64.pointer]
```

We pass `lgdt` the value of our `pointer` label. `lgdt` stands for ‘load global
descriptor table’. That’s it!

We have all of the prerequisites done! In the next section, we will complete our
transition by jumping to long mode.
