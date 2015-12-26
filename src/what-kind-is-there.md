# What kinds of OS are there?

Okay, so here’s the thing: operating systems are made up of a _lot_ of
components. The core component is called a ‘kernel’. So, as OS developers, when
we categorize operating systems, we tend to categorize them by what kinds of
kernel they have. At the start, our ‘operating system’ will be just the kernel,
and so we’ll tend to focus on kernels for the first part of our journey.

The non-kernel bits of an operating system are called a ‘userland’. It’s where
the users live. This is also while you’ll hear some people say, “It’s
GNU/Linux, not Linux.” That’s because virtually all Linux distributions today
use a Linux kernel + a GNU userland. So the GNU folks are a bit annoyed that
the kernel gets all the credit. By the same token, a lot of people say ‘the
kernel’ when they mean ‘the Linux kernel.’ This gets an entirely different set
of people mad.

Sometimes, it just seems like everything makes everyone mad.

Anyway...

The way that we categorize different kernels largely comes down to “what is in
the kernel and what is in userspace.” Upon reading this, you might then think
the easiest kind of kernel to write is the smallest, where everything is in
userspace, but... that’s not actually true. Or at least, it’s not clear that
it’s true.

## Monolithic kernels

First, we have ‘monolithic kernels’. ‘Mono’ meaning ‘one’. One big ‘ol kernel.
Everything that we need, the kernel has it all. A massive, towering achievement
of what we have accomplished.

Most real-world kernels are monolithic kernels, or at least, pretend to be.
Don’t worry about it. Linux, for example, is a monolithic kernel.

## Microkernels

Microkernels are, well, micro. Smaller. The idea is this: if everything is in
the kernel, and something crashes, well, the whole ship is going down. Not
good. So there’s a small core kernel, and then there are components which
communicate with each other to get their job done.

This is a good idea in theory, but historically, microkernels have had issues.
All that communication has overhead, which makes them slower. Various things
have been done to try to mitigate this problem.

Mach, the kernel that Mac OS X uses, is a microkernel. Well, sort of. It ended
up being one, but Mac OS X uses a version of Mach from before that work was
done... so it’s a bit blurry.

GNU Hurd is a microkernel. It’s also kind of a running joke amongst kernel
people. It’s... a long story. Let’s just say that it’s been in development
since 1990. You see, once Linux happened, the need for Hurd was significantly
less, since a free software kernel now existed, and so it’s kind of languished.
There are people still working on it though! We may see a real release someday.

Don’t worry, Hurd will still be more successful than intermezzOS, I’d bet. If
you’re writing kernels for the glory, well, I’ve got some bad news. The vast
majority of kernels, like the vast majority of programs, have been relegated
to the dustbin of history. Don’t have the hubris to assume yours is different.
Life will serve you up some humble pie right quick.

## Exokernels

What’s smaller than a microkernel? An exokernel, of course! An exokernel tries
to only do one thing: securely multiplex hardware. Everything that’s not
directly that lives in user space.

Exokernels are really interesting, but haven’t really made it outside of
university papers on exokernels. The hobby OS I worked on in college was an
exokernel.

There isn’t much to exokernels, so there’s not a lot to say about them.

## Unikernels

Unikernels are kind of like exokernels, but with a fresh paint job and a
Twitter account. Okay, that’s a bit too glib. Unikernels are a major source
of excitement these days. Here’s the idea: an operating system that only
runs one program.

We haven’t really talked enough about the features of operating systems
generally to really discuss more about unikernels and why they matter, and
this isn’t a book about them, so more detail is going to have to have to
wait for another day.
