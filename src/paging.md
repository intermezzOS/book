# Paging

At the end of the last chapter, we did a lot of work that wasn’t actually
writing kernel code. So let’s review what we’re up to:

1. GRUB loaded our kernel, and started running it.
2. We’re currently running in ‘protected mode’, a 32-bit environment.
3. We want to transition to ‘long mode’, the 64-bit environment.
4. In order to do that, we have to do some work.

We’re on step four. More specifically, here’s what we have to do:

1. Set up ‘paging’.
2. Set up a ‘GDT’.
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
memory. There are two major strategies to manage memory: segmentation and
paging. Segmentation is an older strategy, so we won’t talk about it much. It’s
also where the term ‘segmentation fault’ comes from, which is still used today,
even though segementation isn’t used. Old habits die hard.

So let’s talk more about paging. Our computer has memory, and we can think of
memory as being a big long list of cells:

| address | value |
+---------+-------+
| 0x00    | 0     |
| 0x01    | 0     |
| 0x02    | 0     |
| 0x03    | 0     |
| 0x04    | 0     |
| ...     |       |

Each location in memory has an address, and we can use the address to
distinguish between the cells: the value at cell zero, the value at cell ten.
But how many cells are there? This question has two answers: the first answer
is, how many addresses do we have to hand out? In 64-bit mode, we can create
addresses from zero to (2^64) - 1. That’s 18,446,744,073,709,551,616 addresses!
We sometimes refer to a sequence of addresses as an ‘address space’, so we might
say “The full 64-bit address space has 2^64 addresses.” The other answer is, how
much physical RAM do we have in our machine? That will vary per machine. My
machine has 8 gigabytes of memory, 8,589,934,592 bytes. But maybe your machine
has 4 gigabytes of memory, or sixteen gigabytes of memory. How can we make this
work?

Here’s the strategy: we introduce two kinds of addresses: *physical* addresses
and *virtual* addresses. A physical address is the actual, real value of a
location in the physical RAM in the machine. A virtual address is an address
anywhere inside of our 64-bit address space: the full range. To bridge between
the two address spaces, we can map a given virtual address to a particular
physical address. So we might say something like “virtual address 0x044a maps to
the physical address 0x0011.” Software uses the virtual addresses, and the
hardware uses physical addresses.

But how should we do this mapping? Mapping each individual address would be
extremely inefficient; we would need to keep track of literally every memory
address and where it points to. Instead, we split up memory into chunks, also
called ‘pages’, and then map each page to an equal sized chunk of physical
memory.

There’s one more advantage to this strategy: because we’ve introduced an
abstraction, we have some flexibility. We can map virtual pages completely out
of order onto physical pages.


























