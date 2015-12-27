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
userspace. After all, smaller should be easier, right? Well... that’s not
actually true. Or at least, it’s not clear that it’s true.

## Monolithic kernels

First, we have ‘monolithic kernels’. ‘Mono’ meaning ‘one’. One big ‘ol kernel.
Most real-world kernels are monolithic kernels, or at least, pretend to be.
Don’t worry about it. Linux, for example, is a monolithic kernel.

This means that monolithic kernels are kind of ‘the default’. Other kernels
usually define themselves by solving some kind of problem that monolithic
kernels have.

If a monolithic kerenel were a web application, it would be a big ‘ol Rails
application. One repository. A million subdirectories. It may be a big ball
of mud, but it pays the bills.

## Microkernels

Microkernels are, well, micro. Smaller. A lot of the functionality that’s in
the kernel is in userspace instead. This is a good idea in theory, but
historically, microkernels have had issues. All that communication has
overhead, which makes them slower.

Mach, the kernel that Mac OS X uses, is a microkernel. Well, sort of. It ended
up being one, but Mac OS X uses a version of Mach from before that work was
done... so it’s a bit blurry.

If a microkerenel were a web application, it would be made of microservices.
It’s a bit cooler than a single app by itself, and the communication is nice
for flexibility’s sake, but has some overhead.

## Exokernels & Unikernels

These two kinds of operating systems are closely related, but it’s a bit harder
to dig into what exactly makes them different. Unikernels have one
easy-to-describe feature: they only run one single program at a time.
Exokernels are ‘more micro than micro’, but the details aren’t important right
now.

The important thing to know here is that there are a lot of other kinds of
designs than just monolithic vs. micro. There’s a lot of stuff to learn!
