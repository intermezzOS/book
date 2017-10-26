# Paging

At the end of the last chapter, we did a lot of work that wasn’t actually
writing kernel code. So let’s review what we’re up to:

1. GRUB loaded our kernel, and started running it.
2. We’re currently running in ‘protected mode’, a 32-bit environment.
3. We want to transition to ‘long mode’, the 64-bit environment.
4. In order to do that, we have to do some work.

We’re on step four. More specifically, here’s what we have to do:

1. Set up something called ‘paging’.
2. Set up something called a ‘GDT’.
3. Jump to long mode.

This section covers step one. The next two will cover the other two steps.
Afterwards, we’ll be ready to stop writing assembly and start writing Rust!

> **By the way...**
>
> There’s something we’re going to skip here, which we’d want to do in a more
> serious kernel: check to make sure that our hardware can actually do this!
> We’re going to just assume that our ‘hardware’ can run in 64-bit mode, because
> we’re running our OS in QEMU, which supports all of these operations. But if
> we were to run our OS on a real 32-bit computer, it would end up crashing.
> We could check that it’s possible, and then print a nice error message
> instead. But, we won’t cover that here. It’s not particularly interesting, and
> we know that it will never fail. But it might be something you want to explore
> on your own, for extra credit.

## Paging

So, step one: set up ‘paging’. What is paging? Paging is a way of managing
memory. Our computer has memory, and we can think of memory as being a big long
list of cells:

| address | value |
|---------|-------|
| 0x00    | 0     |
| 0x01    | 0     |
| 0x02    | 0     |
| 0x03    | 0     |
| 0x04    | 0     |
| ...     |       |

Each location in memory has an address, and we can use the address to
distinguish between the cells: the value at cell zero, the value at cell ten.

But how many cells are there? This question has two answers: The first answer is
how much physical memory (RAM) do we have in our machine? This will vary per machine.
My machine has 8 gigabytes of memory or 8,589,934,592 bytes. But maybe your machine
has 4 gigabytes of memory, or sixteen gigabytes of memory.

The second answer to how many cells there are is how many addresses can be used
to refer to cells of memory? To answer that we need to figure out how many different
unique numbers we can make. In 64-bit mode, we can create as many addresses as can be
expressed by a 64-bit number. So that means we can make addresses from zero to
(2^64) - 1. That’s 18,446,744,073,709,551,616 addresses! We sometimes refer to a
sequence of addresses as an ‘address space’, so we might say “The full 64-bit address
space has 2^64 addresses.”

So now we have an imbalance. We have only roughly 8.5 billion actual physical memory
slots in an 8GB machine but quintillions of possible addresses we can make.

How can we resolve this imbalance? We don't want to be able to address memory
that doesn't exist!

Here’s the strategy: we introduce two kinds of addresses: *physical* addresses
and *virtual* addresses. A physical address is the actual, real value of a
location in the physical RAM in the machine. A virtual address is an address
anywhere inside of our 64-bit address space: the full range. To bridge between
the two address spaces, we can map a given virtual address to a particular
physical address. So we might say something like “virtual address 0x044a maps to
the physical address 0x0011.” Software uses the virtual addresses, and the
hardware uses physical addresses.

Mapping each individual address would be extremely inefficient; we would need
to keep track of literally every memory address and where it points to.
Instead, we split up memory into chunks, also called ‘pages’, and then map each
page to an equal sized chunk of physical memory.

> **By the way...**
> In the future we'll be using paging to help us implement something called
> "virtual memory". Besides helping us always be able to map a 64-bit number to
> a real place in physical memory, "virtual memory" is useful for other reasons.
> These reasons don't really come into play at this point, so we'll hold off on
> discussing them. For now, it's just important to know that we need paging to
> enter 64-bit long mode and that it's a good idea for many reasons including
> helping us resolve the fact the we have way less actual memory than possible
> addresses to refer to that memory.

Paging is actually implemented by a part of the CPU called an ‘MMU’, for ‘memory
management unit’. The MMU will translate virtual addresses into
their respective physical addresses automatically; we can write all of our
software with virtual addresses only. The MMU does this with a data structure
called a ‘page table’. As an operating system, we load up the page table with a
certain data structure, and then tell the CPU to enable paging. This is the task
ahead of us; it’s required to set up paging before we transition to long mode.

How should we do our mapping of physical to virtual addresses? You can make
this easy, or complex, and it depends on exactly what you want your OS to
be good at. Some strategies are better than others, depending on the kinds of
programs you expect to be running. We’re going to keep it simple, and use a
strategy called ‘identity mapping’. This means that every virtual address will
map to a physical address of the same number. Nothing fancy.

Let’s talk more about the page table. In long mode, the page table is four
levels deep, and each page is 4096 bytes in size. What do I mean by levels?
Here are the official names:

*  the Page-Map Level-4 Table (PML4),
*  the Page-Directory Pointer Table (PDP),
*  the Page-Directory Table (PD),
*  and the Page Table (PT).

I’ve most commonly heard them referred to as a “level x page table”, where `x`
goes from four to one. So the PML4 is a “level four page table,” and the PT is
a “level one page table.” They’re called ‘levels’ because they decend in order:
each entry in a level 4 page table points to a level 3 page table entry. Each
level 3 page table entry points at a level 2 page table entry, and each level 2
page table entry points at a level 1 page table entry. That entry then contains
the address. Whew! To get started, we only need one entry of each table.

## Creating the page table

So here’s the strategy: create a single entry of each of these tables, then
point them at each other in the correct way, then tell the CPU that paging
should be enabled.

### How many tables?

The number of tables we need depends on how big we make each page. The bigger
each page, the fewer pages fit into the virtual address space, so the fewer
tables we need. How to choose a page size is the kind of detail we don't need to
worry about for now. We're just going to go for 2 MiB pages, which means we only
need three tables: we won't need a level 1 page table.

### Creating page table entries

To create space for these page table entries, open up `boot.asm` and add these
lines at the bottom:

```x86asm
section .bss

align 4096

p4_table:
    resb 4096
p3_table:
    resb 4096
p2_table:
    resb 4096
```

We introduce a new section, ‘bss’. It stands for ‘block started by symbol’, and
was introduced in the 1950s. The name doesn’t make much sense anymore, but the
reason we use it is because of its behavior: entries in the bss section are
automatically set to zero by the linker. This is useful, as we only want certain
bits set to 1, and most of them set to zero.

The `resb` directive reserves bytes; we want to reserve space for each entry.

The `align` directive makes sure that we’ve aligned our tables properly. We
haven’t talked much about alignment yet: the idea is that the addresses here
will be set to a multiple of 4096, hence ‘aligned’ to 4096 byte chunks. We’ll
eventually talk more about alignment and why it’s important, but it doesn’t
matter a ton right now.

After this has been added, we have a single valid entry for each level.
However, because our page four entry is all zeroes, we have no valid pages.
That’s not super useful. Let’s set things up properly.

### Pointing the entries at each other

In order to do this setup, we need to write some more assembly code! Open up
`boot.asm`. You can either leave in printing code, or remove it. If you do leave
it in, add this code before it: that way, if you see your message print out, you
know it ran successfully.

```x86asm
global start

section .text
bits 32
start:
    ; Point the first entry of the level 4 page table to the first entry in the
    ; p3 table
    mov eax, p3_table
    or eax, 0b11
    mov dword [p4_table + 0], eax
```

If you recall, `;` are comments. Leaving yourself excessive comments in assembly
files is a good idea. Let’s go over each of these lines:

```x86asm
    mov eax, p3_table
```

This copies the contents of the first third-level page table entry into the
`eax` register. We need to do this because of the next line:

```x86asm
    or eax, 0b11
```

We take the contents of `eax` and `or` it with `0b11`, the result is written in `eax`. First, let’s talk about
_what_ this does, and then we’ll talk about _why_ we want to do it.

When dealing with binary, `or` is an operation that returns `1` if either value
is `1`, and `0` if both are `0`. In other words, if `a` and `b` are a single
binary digit:

|        |   |   |   |   |
|--------|---|---|---|---|
| a      | 0 | 1 | 0 | 1 |
| b      | 0 | 0 | 1 | 1 |
| or a b | 0 | 1 | 1 | 1 |

You’ll see charts like this a lot when talking about binary stuff. You can read
this chart from top to bottom, each column is a case. So the first column says
“if `a` is zero and `b` is zero, `or a b` will be zero.” The second column says
“if `a` is one and `b` is zero, `or a b` will be one.” And so on.

So when we `or` with `0b11`, it means that the first two bits will be set to
one, leaving the rest as they were.

Okay, so now we know _what_ we are doing, but _why_? Each entry in a page table
contains an address, but it also contains metadata about that page. The first
two bits are the ‘present bit’ and the ‘writable bit’. By setting the first bit,
we say “this page is currently in memory,” and by setting the second, we say
“this page is allowed to be written to.” There are a number of other settings we
can change this way, but they’re not important for now.

> **By the way...**
>
> You might be wondering, if the entry in the page table is an address, how can
> we use some of the bits of that address to store metadata without messing up
> the address? Remember that we used the `align` directive to make sure that the
> page tables all have addresses that are multiples of 4096. That means that the
> CPU can assume that the first 12 bits of all the addresses are zero. If
> they're always implicitly zero, we can use them to store metadata without
> changing the address.

Now that we have an entry set up properly, the next line is of interest:

```x86asm
    mov dword [p4_table + 0], eax
```

Another `mov` instruction, but this time, copying `eax`, where we’ve been
setting things up, into... something in brackets. `[]` means, “I will be giving
you an address between the brackets. Please do something at the place this
address points.” In other words, `[]` is like a dereference operator.

Now, the address we’ve put is kind of funny looking: `p4_table + 0`. What’s up
with that `+ 0`? It’s not strictly needed: adding zero to something keeps it the
same. However, it’s intended to convey to the reader that we’re accessing the
zeroth entry in the page table. We’re about to see some more code later where we
will do something other than add zero, and so putting it here makes our code
look more symmetric overall. If you don’t like this style, you don’t have to put
the zero.

These few lines form the core of how we’re setting up these page tables. We’re
going to do the same thing over again, with slight variations.

Here’s the full thing again:

```x86asm
    ; Point the first entry of the level 4 page table to the first entry in the
    ; p3 table
    mov eax, p3_table
    or eax, 0b11 ;
    mov dword [p4_table + 0], eax
```

Once you feel like you’ve got a handle on that, let’s move on to pointing the
page three table to the page two table!

```x86asm
    ; Point the first entry of the level 3 page table to the first entry in the
    ; p2 table
    mov eax, p2_table
    or eax, 0b11
    mov dword [p3_table + 0], eax
```

The code is the same as above, but with `p2_table` and `p3_table` instead of
`p3_table` and `p4_table`. Nothing more than that.

We have one last thing to do: set up the level two page table to have valid
references to pages. We’re going to do something we haven’t done yet in
assembly: write a loop!

Here’s the basic outline of loop in assembly:

* Create a counter variable to track how many times we’ve looped
* make a label to define where the loop starts
* do the body of the loop
* add one to our counter
* check to see if our counter is equal to the number of times we want to loop
* if it’s not, jump back to the top of the loop
* if it is, we’re done

It’s a little more detail-oriented than loops in other languages. Usually, you
have curly braces or indentation to indicate that the body of the loop is
separate, but we don’t have any of those things here. We also have to write the
code to increment the counter, and check if we’re done. Lots of little fiddly
bits. But that’s the nature of what we’re doing!

Let’s get to it!

```x86asm
    ; point each page table level two entry to a page
    mov ecx, 0         ; counter variable
```

In order to write a loop, we need a counter. `ecx` is the usual loop counter
register, that’s what the `c` stands for: counter. We also have a comment
indicating what we’re doing in this part of the code.

Next, we need to make a new label:

```x86asm
.map_p2_table:
```

As we mentioned above, this is where we will loop back to when the loop
continues.

```x86asm
    mov eax, 0x200000  ; 2MiB
```

We’re going to store 0x200000 in `eax`, or 2,097,152 which is equivalent to 2 MiB. 
Here’s the reason: each page is two megabytes in size. So in order to get the 
right memory location, we will multiply the number of the loop counter by 0x200000:


|            |         |         |         |         |         |
|------------|---------|---------|---------|---------|---------|
| counter    | 0       | 1       | 2       | 3       | 4       |
| 0x200000   | 0x200000| 0x200000| 0x200000| 0x200000| 0x020000|
| multiplied | 0       | 0x200000| 0x400000| 0x600000| 0x800000|

And so on. So our pages will be all next to each other, and 2,097,152 bytes in
size.

```x86asm
    mul ecx
```

Here’s that multiplication! `mul` takes just one argument, which in this case
is our `ecx` counter, and multiplies that by `eax`, storing the result in
`eax`. This will be the location of the next page.

```x86asm
    or eax, 0b10000011
```

Next up, our friend `or`. Here, we don’t just or `0b11`: we’re also setting
another bit. This extra `1` is a ‘huge page’ bit, meaning that the pages are
2,097,152 bytes. Without this bit, we’d have 4KiB pages instead of 2MiB pages.

```x86asm
    mov [p2_table + ecx * 8], eax
```

Just like before, we are now writing the value in `eax` to a location. But
instead of it being just `p2_table + 0`, we’re adding `ecx * 8`. Remember, `ecx`
is our loop counter. Each entry is eight bytes in size, so we need to multiply
the counter by eight, and then add it to `p2_table`. Let’s take a closer look:
let’s assume `p2_table` is zero, to make the math easier:

|                     |         |         |         |         |         |
|---------------------|---------|---------|---------|---------|---------|
| p2\_table           | 0       | 0       | 0       | 0       | 0       |
| ecx                 | 0       | 1       | 2       | 3       | 4       |
| ecx * 8             | 0       | 8       | 16      | 24      | 32      |
| p2\_table + ecx * 8 | 0       | 8       | 16      | 24      | 32      |

We skip eight spaces each time, so we have room for all eight bytes of the page
table entry.

That’s the body of the loop! Now we need to see if we need to keep looping or
not:

```x86asm
    inc ecx
    cmp ecx, 512
    jne .map_p2_table
```

The `inc` instruction increments the register it’s given by one. `ecx` is our
loop counter, so we’re adding to it. Then, we ‘compare’ with `cmp`. We’re
comparing `ecx` with 512: we want to map 512 page entries overall. The page
table is 4096 bytes, each entry is 8 bytes, so that means there are 512 entries.
This will give us 512 * 2 mebibytes: one gibibyte of memory. It’s also why we
wrote the loop: writing out 512 entries by hand is possible, theoretically, but
is not fun. Let’s make the computer do the math for us.

The `jne` instruction is short for ‘jump if not equal’. It checks the result of
the `cmp`, and if the comparison says ‘not equal’, it will jump to the label
we’ve defined. `map_p2_table` points to the top of the loop.

That’s it! We’ve written our loop and mapped our second-level page table. Here’s
the full code of the loop:

```x86asm
    ; point each page table level two entry to a page
    mov ecx, 0         ; counter variable
.map_p2_table:
    mov eax, 0x200000  ; 2MiB
    mul ecx
    or eax, 0b10000011
    mov [p2_table + ecx * 8], eax

    inc ecx
    cmp ecx, 512
    jne .map_p2_table
```

And, with this, we’ve now fully mapped our page table! We’re one step closer to
being in long mode. Here’s the full code, all in one place:

```x86asm
    ; Point the first entry of the level 4 page table to the first entry in the
    ; p3 table
    mov eax, p3_table
    or eax, 0b11 ;
    mov dword [p4_table + 0], eax

    ; Point the first entry of the level 3 page table to the first entry in the
    ; p2 table
    mov eax, p2_table
    or eax, 0b11
    mov dword [p3_table + 0], eax

    ; point each page table level two entry to a page
    mov ecx, 0         ; counter variable
.map_p2_table:
    mov eax, 0x200000  ; 2MiB
    mul ecx
    or eax, 0b10000011
    mov [p2_table + ecx * 8], eax

    inc ecx
    cmp ecx, 512
    jne .map_p2_table
```

Now that we’ve done this, we have a valid initial page table. Time to enable paging!

### Enable paging

Now that we have a valid page table, we need to inform the hardware about it.
Here’s the steps we need to take:

* We have to put the address of the level four page table in a special register
* enable ‘physical address extension’
* set the ‘long mode bit’
* enable paging

These four steps are not particularly interesting, but we have to do them.
First, let’s do the first step:

```x86asm
    ; move page table address to cr3
    mov eax, p4_table
    mov cr3, eax
```

So, this might seem a bit redundant: if we put `p4_table` into `eax`, and then
put `eax` into `cr3`, why not just put `p4_table` into `cr3`? As it turns out,
`cr3` is a special register, called a ‘control register’, hence the `cr`. The
`cr` registers are special: they control how the CPU actually works. In our
case, the `cr3` register needs to hold the location of the page table.

Because it’s a special register, it has some restrictions, and one of those is
that when you `mov` to `cr3`, it has to be from another register. So we need the
first `mov` to set `p4_table` in a register before we can set `cr3`.

Step one: done!

Next, enabling ‘physical address extension’:

```x86asm
    ; enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax
```

In order to set PAE, we need to take the value in the `cr4` register and
modify it. So first, we `mov` it into `eax`, then we use `or` to change the
value. What about `1 << 5`? The `<<` is a ‘left shift’. It might be easier to
show you with a table:

|       |  value |
|-------|--------|
| 1     | 000001 |
|  << 1 | 000010 |
|  << 2 | 000100 |
|  << 3 | 001000 |
|  << 4 | 010000 |
|  << 5 | 100000 |

See how the 1 moves left? So `1 << 5` is `100000` (or 2^5 if you like maths; incidentally 1<<n = 2^n). If you only need to set one
bit, this can be easier than writing out `100000` itself, as you don’t need to
count the zeroes.

After we modify `eax` to have this bit set, we `mov` the value back into `cr4`.
PAE has been set! Why is this what you need to do? It just is. The details are
not really in the scope of this tutorial.

Okay, so we have step two done. Time for step three: setting the long mode bit:

```x86asm
    ; set the long mode bit
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr
```

The `rdmsr` and `wrmsr` instructions read and write to a ‘model specific
register’, hence `msr`. This is just what you have to do to set this up. Again,
we won’t get into too much detail, as it’s not very interesting. Boilerplate.

Finally we are all ready to enable paging!

```x86asm
    ; enable paging
    mov eax, cr0
    or eax, 1 << 31
    or eax, 1 << 16
    mov cr0, eax
```

`cr0` is the register we need to modify. We do the usual “move to `eax`, set
some bits, move back to the register” pattern. In this case, we set bit 31 and
bit 16.

Once we’ve set these bits, we’re done! Here’s the full code listing:

```x86asm
    ; move page table address to cr3
    mov eax, p4_table
    mov cr3, eax

    ; enable PAE
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; set the long mode bit
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; enable paging
    mov eax, cr0
    or eax, 1 << 31
    or eax, 1 << 16
    mov cr0, eax
```

## ... are we in long mode yet?

So, _technically_ after paging is enabled, we are in long mode. But we’re not
in _real_ long mode; we’re in a special compatibility mode. To get to real long
mode, we need a data structure called a ‘global descriptor table’. Read the next
section to find out how to make one of these.
