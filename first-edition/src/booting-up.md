# Booting up

We’ve got some of the theory down, and we’ve got a development environment
going. Let’s get down to actually writing some code, shall we?

Our first task is going to be the same as in any programming language: Hello
world! It’s going to take a _teeny_ bit more code than in many languages. For
example, here’s “Hello, World!” in Ruby:

```ruby
puts "Hello, world!"
```

Or in C:

```c
#include<stdio.h>

int main(void) {
    printf("Hello, world!");
}
```

But it’s not actually _that_ much more work. It’s going to take us *28 lines*
to get there. And instead of a single command to build and run, like Ruby:

```bash
$ ruby hello_world.rb
```

It’s going to initially take us six commands to build and run our hello world
kernel. Don’t worry, the next thing we’ll do is write a script to turn it back
into a single command.

By the way, [Appendix A](appendix/troubleshooting.html) has a list of solutions
to common problems, if you end up getting stuck.
