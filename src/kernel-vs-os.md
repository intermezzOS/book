# Kernel vs. OS

One term you’ll hear thrown around a lot in operating systems is ‘kernel’.
There’s a distinction between ‘the kenerl’ and ‘userland programs’. You can
see it in the grammar: it’s _the_ kernel vs program *s*, singular versus
multiple.

A full-fledged operating system is often comprised of multiple programs. The
kernel is the program at the heart of the OS: it’s in charge of talking to
hardware, and keeping track of everything. Other programs run on top of the
kernel, making use of its services.

One way to think about a kernel is that it’s the program that controls
the shared resources between programs. You can think of it like giant mutex,
making sure that programs don’t try to use the same stuff at the same time.
It also makes sure that a particular program isn’t hogging too many resources
on the system.

As such, we’ll start off making a kernel. Eventually, our kernel will be able
to run other programs. But not at the start.

There are various ways in which a kernel can be designed. The classic two
are ‘monolithic kernel’ vs ‘microkernel’, but there are others as well,
like an ‘exokernel’ or a ‘unikernel’. We’re not going to worry about this
level of detail yet. We haven’t even started! You can spend a lot of time
making plans, but never actually develop your system. So we won’t worry
about what kind of kernel we’re making for now, and just worry about
making it do things at all.
