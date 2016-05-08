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
memory. Our computer has memory, and we can think of memory as being a big long
list of cells:

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

Mapping each individual address would be extremely inefficient; we would need
to keep track of literally every memory address and where it points to.
Instead, we split up memory into chunks, also called ‘pages’, and then map each
page to an equal sized chunk of physical memory.

Paging is actually implemented by the a part of the CPU called an ‘MMU’, for
‘memory management unit’. The MMU will automatically translate virtual
addresses into their respective physical addresses automatically; we can write
all of our software with virtual addresses only. The MMU does this with a data
structure called a ‘page table’. As an operating system, we load up the page
table with a certain data structure, and then tell the CPU to enable paging.
This is the task ahead of us; it’s required to set up paging before we
transition to long mode.

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

```x86asm
set_up_page_tables:
    ; P4, P3 and P2
    ; P4 --> point first entry to (first entry in) P3
    mov eax, p3_table
    or eax, 0b11
    mov dword [p4_table + 0], eax

    ; P3 --> point first entry to (first entry in) P2
    mov eax, p2_table
    or eax, 0b11
    mov dword [p3_table + 0], eax

    ; P2 --> point each entry to a 2MiB page
    mov ecx, 0         ; counter variable
.map_p2_table:
    ; map ecx-th P2 entry to a huge page that starts at address 2MiB*ecx
    mov eax, 0x200000  ; 2MiB
    mul ecx            ; start address of ecx-th page
    or eax, 0b10000011 ; present + writable + huge
    mov [p2_table + ecx * 8], eax ; map ecx-th entry

    inc ecx            ; increase counter
    cmp ecx, 512       ; if counter == 512, the whole P2 table is mapped
    jne .map_p2_table  ; else map the next entry

    ret
```

Now that we’ve done this, we have a valid initial page table. Time to enable paging!

### Enable paging


```x86asm
enable_paging:
    ; load P4 to cr3 register (cpu uses this to access the P4 table)
    mov eax, p4_table
    mov cr3, eax

    ; enable PAE-flag in cr4 (Physical Address Extension)
    mov eax, cr4
    or eax, 1 << 5
    mov cr4, eax

    ; set the long mode bit in the EFER MSR (model specific register)
    mov ecx, 0xC0000080
    rdmsr
    or eax, 1 << 8
    wrmsr

    ; enable paging in the cr0 register
    mov eax, cr0
    or eax, 1 << 31
    or eax, 1 << 16
    mov cr0, eax

    ret
```

## ... are we in long mode yet?

So, _technically_ after paging is enabled, we are in long mode. But we’re not
in _real_ long mode; we’re in a special compatibility mode. To get to real long
mode, we need a data structure called a ‘global descriptor table’. Read the next
section to find out how to make one of these.



















