<h1 class="center">intermezzOS</h1>

<img class="center" src="rhizome.jpg" alt="rhizome" />

<p class="center">An operating system for learning</p>

## Preface

This book describes the intermezzOS project. intermezzOS is a hobby operating
system, specifically targeted at showing beginners how to get into operating
systems development. Rather than describe some sort of final OS, it instead
proceeds in a tutorial-like fashion, allowing you to implement intermezzOS
yourself, alongside the book.

The book assumes that you have programmed in some language before, but not any
particular one. In fact, people who have not done low-level programming before
are a specific target of this book; I’ll be explaining a lot of things that
other resources will just assume that you know.

intermezzOS is implemented in [Rust](https://www.rust-lang.org/), and some
assembly code. We’ll try to explain Rust along the way, but may refer you to
its documentation when things get tricky. This book isn’t _really_ about
learning Rust, but you might accidentally along the way.

You can find all of this stuff [on GitHub](https://github.com/intermezzOS/).
This book is in the `book` repository, the kernel is in `kernel`, and the
website is there too. Feel free to open issues on the [RFCs
repo](https://github.com/intermezzOS/rfcs) if you want to discuss things
in a general sense, and send bug reports and PRs to the appropriate repos
if you’d like to help with a particular component.

## The Story

A long time ago, in college, my friends and I were working on a hobby operating
system, [XOmB](http://xomb.org). It was... tough. Frankly, while I learned a
lot, I was a pretty minor contributor. I got frustrated too easily. One day, I
found Ruby, and I was pretty much done with low-level programming. I had done
it most of my life, and I was bored. Bored, and sick of dealing with core
dumps.

Those details aren’t that important. What is important is that over the years,
I’ve always wanted to get back into this stuff. But the problem is this: there
are a lot of people who do hobby operating system work, but... I don’t like
their attitudes.

You see, a lot of people see low-level programming as some kind of superior,
only-for-the-smartest kind of thing. They have a puritanical world-view: “I
suffered to learn this, so you too must suffer to build character.” I think
that’s short sighted. Low level programming _is_ difficult to get into, but
that says more about the teachers’ faults than the students’.

Anyway, as my professional life has moved back towards the low level, I’ve been
thinking about this topic a lot again. That’s when I found an awesome link:
[Writing an OS in Rust by Philipp Oppermann][phil]. I cannot speak enough
about how awesome Phil’s tutorial is; it single-handedly inspired me to get
back into operating systems.

[phil]: http://os.phil-opp.com/multiboot-kernel.html

The big difference with Phil’s tutorial is that it doesn’t treat you as being
stupid for not knowing ‘the basics’. It doesn’t say “spend hours debugging this
thing, because I did.” It doesn’t insult you for being new. It just explains
the basics of a kernel.

It’s amazing how much a little bit of a framing can completely change the way
you see something. When the examples I found were all about how you have to be
an amazing rockstar ninja and we won’t give you all the code because you suck
if you can’t figure it out, I hated this stuff. When it was kind,
understanding, and helpful, I couldn’t get enough.

Once I got to a certain part in Phil’s tutorial, I started implementing stuff
myself. A lot of the initial code here is going to be similar to Phil’s.
But I’m going to write about it anyway. There’s a good reason for that:

> Writing is nature’s way of showing us how sloppy our thinking is.
>
> - Leslie Lamport

By re-explaining things in my own words, I hope to understand it even better.
This is just a perpetual theme with me: I like teaching because it helps me
learn. I like writing because it helps me understand.

The first section of the book is going to be clear about where we’re following
Phil, and where we break off and go into our own little world. After the start,
things will end up diverging.

Furthermore, I will not commit to any kind of schedule for this project. It’s
going to be in my spare time, and I’m learning a lot of this as I go, too.

## The Name

> The nomad has a territory; he follows customary paths; he goes from one point
> to another; he is not ignorant of points (water points, dwelling points,
> assembly points, etc.). But the question is what in nomad life is a principle
> and what is only a consequence. To begin with, although the points determine
> paths, they are strictly subordinated to the paths they determine, the
> reverse happens with the sedentary. The water point is reached only in order
> to be left behind; every point is a relay and exists only as a relay. A path
> is always between two points, but the in-between has taken on all the
> consistency and enjoys both an autonomy and a direction of its own. The life
> of the nomad is the intermezzo.
>
> Deleuze and Guattari, “A Thousand Plateaus”, p380

If you’re not into particular kinds of philosophy, this quote won’t mean a lot.
Let’s look at the dictionary definition:

> An intermezzo, in the most general sense, is a composition which fits between
> other musical or dramatic entities, such as acts of a play or movements of a
> larger musical work.
>
> [https://en.wikipedia.org/wiki/Intermezzo](https://en.wikipedia.org/wiki/Intermezzo)

I want this project to be about learning. Learning is often referred to as a
journey. You start off in ignorance and end in knowledge. In other words,
‘learning’ is that part in the middle, the in-between state.

The tricky thing about learning is, you never stop learning. Once you learn
something, there’s something new to learn, and you’re on a journey again.

If you want to learn a lot, then you’ll find yourself perpetually in the
middle.

There is another sense by which this name makes sense: as we’ll learn in the
beginning of the book, operating systems are largely about abstractions. And
abstractions are themselves ‘in the middle’, between what they’re abstracting
and who they are abstracting it for.

## Principles

Here are the guiding principles of intermezzOS:

* We’re all actual people. Please treat each other as such.
* We’re all here to learn. Let’s help each other learn, rather than being some
  kind of vanguard of knowledge.
* The only thing that matters about your language background is the amount you
  may have to learn.
* Everything must be documented, or it’s not done.

And of course, everything related to this project is under the [Code of
Conduct](http://intermezzos.github.io/code-of-conduct.html).
