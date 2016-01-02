# Running in QEMU

Let’s actually run our kernel! To do this, we’ll use QEMU, an emulator. Using
QEMU is fairly straightfoward:

```bash
$ qemu-system-x86_64 -drive format=raw,file=os.iso
```

Type it in, hit enter, and you should see Hello World!

<img alt="hello world" class="center" src="assets/hello_world.png" />

If it shows up for you too, congrats! If not, something may have gone
wrong. Double check that you followed the examples _exactly_. Maybe
you missed something, or made a mistake while copying things down.

Let’s talk about this command before we move on:

```text
qemu-system-x86_64
```

We’re running the `x86_64` varient of QEMU. While we have a 32-bit kernel for
now, soon we’ll have a 64-bit one. And since things are backwards compatible,
this works just fine.

```text
-drive
```

This flag defines a ‘drive’, like a hard drive, or floppy drive. In other
words, this is going to be the hard drive our emulator will use.

```text
format=raw,file=os.iso
```

These options explain what kind of drive we have. In this case, since we have
an ISO, we want it to be the `raw` format, and we’re passing in our `os.iso`
file as the source of the drive.

That’s it! Here’s the thing, though: while that wasn’t _too_ complicated, it
was a lot of steps. Each time we make a change, we have to go through all these
steps over again. In the next section, we’ll use Make to do all these steps for
us.
