# Printing to the screen: a text mode VGA driver

Now that we can build and run our new kernel, it's time to make it actually
do someting! We'll get started by printing stuff to the screen. PC-compatible
computers implement a graphics API called "VGA", or "video graphics array."
You'll come to learn quite soon why that's the name!

First, we'll write out the simplest "hello world" possible. Then, we'll dig
a bit deeper into exactly what we did. Finally, we'll refactor our code into
an actual, nice-to-use library.