# What does an OS do?

If we want to build an operating system, we should first define what an
operating system actually is.

As it turns out, this is kind of hard. There are a few different ways
to tackle this question, but then there are operating systems that
buck the trend and can make your categorization difficult. For example,
a simple definition of an operating system might be “a program that
runs on your computer and allows you to run other programs.” But
unikernels make this definition unworkable.

The [comet book] believes that operating systems are made up of three
big features: virtualization, concurrency, and persistence.

[comet book]: http://pages.cs.wisc.edu/~remzi/OSTEP/

[Wikipedia] has a different definition:

> An operating system (OS) is system software that manages computer hardware
> and software resources and provides common services for computer programs.
> The operating system is a component of the system software in a computer
> system. Application programs usually require an operating system to function.

[Wikipedia]: https://en.wikipedia.org/wiki/Operating_system

I am not particularly interested in being the Arbiter of What Opearting Systems
Are. However, I can tell you what intermezzOS will do:

> intermezzOS will provide an *abstraction of the hardware* for other programs
> to use.

To me, this is the core of an operating system. Very few people want to write
programs that are for one specific computer; they want to write programs that
work on lots of computers. To solve this problem, we introduce a program which
provides an abstraction: it will deal with the details of particular kinds of
hardware, and then provide an interface for other programs. Those programs will
can use its abstractions to not have to think about those details.

It’s kind of like a framework. You can build an application that’s a one-off, or
you can work with a framework that gives you common abstractions. An operating
system is sort of like Ruby on Rails, but for hardware.

The devil, of course, is in the details.
