# What is an OS?

It’s actually kind of difficult to define what an operating system is. There
are a lot of different kinds of operating systems, and they all do different
kinds of things.

There are some shared goals, however. Let’s try this out as a working
definition:

> An operating system is a program that provides a platform for other
> programs. It provides two things to these programs: abstractions and
> isolation.

This is good enough for now. Let’s consider this a test for inclusion,
but not exclusion. In other words, things that fit this definition
_are_ operating systems, but things that don’t may or may not be,
we don’t quite know.

## Creating abstractions

There are many reasons to create a platform for other programs, but a
common one for operating systems is to abstract over hardware.

Consider a program, running on some hardware:

** DIAGRAM GOES HERE **

This program will need to know _exactly_ about what kind of hardware exists.
If you want to run it on a different computer, it will have to know exactly
about that computer too. And if you want to write a second program, you’ll
have to re-write all of that code.

> All problems in computer science can be solved by another level of
> indirection.
> 
> - David Wheeler

To solve this problem, we can introduce an abstraction:

** DIAGRAM GOES HERE **

Now, the operating system can handle the details of the hardware, and provide
an API for it. A program can be written for that operating system’s API, and
can then run on any hardware that the operating system supports.

At some point, though, we developed many operating systems. Since operating
systems are platforms, most people pick one and have only that one on their
computer. So now we have a problem that looks the same, but is a bit
different: our program is now specific to an OS, rather than specific to
a particular bit of hardware.

To solve this, some programming languages have a ‘virtual machine.’ This
was a bit selling point of Java, for example: the Java Virtual Machine.
The idea here is that we create a _virtual_ machine on top of the _real_
machine.

** DIAGRAM GOES HERE **

Now, you write programs for the Java Virtual Machine, which is then ported
to each operating system, which is then ported to all the hardware. Whew!

> ...except for the problem of too many layers of indirection.
> 
> - Kevlin Henney

Now consider this: what if we have a big server, and we want to run a bunch of
services on it? Well, we can write a special kind of operating system, a
‘hypervisor’, whose client programs are operating systems:

** DIAGRAM GOES HERE **

Now we have hardware, which is abstracted by a hypervisor. We then have
an operating system, providing a layer on top of the hypervisor. From
there, we have a virtual machine, abstracting over operating systems.

Then inside that, we have our program. Whew!

The point is, ‘hypervisors’, ‘operating systems’, and ‘virtual machines’
are all sort of the same thing, in a sense. They do the same kind of
job; it’s just what is on top of and below them that’s different.

## Isolation

Many of the abstractions provided are, as we discussed, abstractions over
hardware. And hardware often has a pretty serious restriction: only one
program can access the hardware at a time. So if our operating system is going
to be able to run multiple programs, which is a common feature of many
operating systems, we’ll also need to make sure that multiple programs cannot
access hardware at the same time.

This really applies to more than just hardware though: once we have two
programs, it would not be ideal to let them mess with each other. Consider any
sort of program that deals with your password: if programs could mess with each
other’s memory and code, then a program could trivially steal your password
from another program!

This is just one symptom of a general problem. It’s much better to isolate
programs from each other, for a number of different reasons. For now, we’ll
just consider isolation as one of our important jobs, as OS authors.


