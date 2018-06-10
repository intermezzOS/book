# Interlude: fractal learning

At this point, we're about to start actually learning about how an OS works,
and start writing real code. Before we do, I'd like to explain *how* we're
going to learn this stuff. I think this framing is important. I know you're
probably excited to get going, but please bear with me for a moment!

It's impossible to learn everything at once. If you keep digging, you'll find
more questions, and digging into those questions leads to more questions...
at some point, you have to say "okay, I know enough about this for now, it's
time to move on." You can always come back to a concept later. And sometimes,
you have to go back and forth between different levels of abstraction
numerous times to truly *get it*. This spirals out, like a fractal, with
an infinite level of zooming in and out.

I think this is something most programmers *know*, but it can be hard to
remember when working on a hobby operating system. I sometimes think to
myself, "Isn't the whole point that I'm trying to learn all the things, all
the way down? Is skimming this concept for now okay? Am I cheating?"

The answer, of course, is 'no'. There is no cheating. We're doing this to
learn. We'll learn some things at a certain level of abstraction, and
then come back to them later and learn more. That's just the way this works.
And it *also* means that sometimes, the chapters you're about to read will
say "This is the way this is. It just is. You memorize it and move on." We're
about to talk about printing characters to the screen, in various colors.
Yellow is represented by a certain number. Why specifically that number?
Well, there is a good reason, but it's 100% irrelevant to writing a yellow
character on the screen. So we say "This color means yellow" and just get
on with life. I've written this VGA code probably ten different times in
at least three different languages in the past ten years, and I didn't know
why that number meant yellow until last night. In the previous sections, we
managed to build a whole "hello world" kernel without understanding fully
what was going on. We then circled back and dug in a bit.

It's okay to not "fully" understand something before moving on, whatever
that means. You'll get back to it. Sometimes, learning something else is
more important than diving into every last detail. And, since you now
have the words to understand what it is you need to learn, coming back
to the topic later is even easier. You have the terms to search for.