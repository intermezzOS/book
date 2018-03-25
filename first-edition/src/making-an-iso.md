# Making an ISO

Now that we have our `kernel.bin`, the next step is to make an ISO. Remember
compact discs? Well, by making an ISO file, we can both test our Hello World
kernel in QEMU, as well as running it on actual hardware!

To do this, we’re going to use a GRUB tool called `grub-mkrescue`. We have to
create a certain structure of files on disk, run the tool, and we’ll get an
`os.iso` file at the end.

Doing so is not very much work, but we need to make the files in the right
places. First, we need to make three directories:

```bash
$ mkdir -p isofiles/boot/grub
```

The `-p` flag to `mkdir` will make the directory we specify, as well as any
‘parent’ directories, hence the `p`. In other words, this will make an
`isofiles` directory, with a `boot` directory inside, and a `grub` directory
inside of that.

Next, create a `grub.cfg` file inside of that `isofiles/boot/grub` directory,
and put this in it:

```text
set timeout=0
set default=0

menuentry "intermezzOS" {
    multiboot2 /boot/kernel.bin
    boot
}
```

This file configures GRUB. Let’s talk about the `menuentry` block first.
GRUB lets us load up multiple different operating systems, and it usually does
this by displaying a menu of OS choices to the user when the machine boots. Each
`menuentry` section corresponds to one of these. We give it a name, in this
case, `intermezzOS`, and then a little script to tell it what to do. First,
we use the `multiboot2` command to point at our kernel file. In this case,
that location is `/boot/kernel.bin`. Remember how we made a `boot` directory
inside of `isofiles`? Since we’re making the ISO out of the `isofiles` directory,
everything inside of it is at the root of our ISO. Hence `/boot`.

Let’s copy our `kernel.bin` file there now:

```bash
$ cp kernel.bin isofiles/boot/
```

Finally, the `boot` command says “that’s all the configuration we need to do,
boot it up.“

But what about those `timeout` and `default` settings? Well, the `default` setting
controls which `menuentry` we want to be the default. The numbers start at zero,
and since we only have that one, we set it as the default. When GRUB starts, it
will wait for `timeout` seconds, and then choose the `default` option if the user
didn’t pick a different one. Since we only have one option here, we just set it to
zero, so it will start up right away.

The final layout should look like this:

```text
isofiles/
└── boot
    ├── grub
    │   └── grub.cfg
    └── kernel.bin
```

Using `grub-mkrescue` is easy. We run this command:

```bash
$ grub-mkrescue -o os.iso isofiles
```

The `-o` flag controls the *o*utput filename, which we choose to be `os.iso`.
And then we pass it the directory to make the ISO out of, which is the
`isofiles` directory we just set up.

After this, you have an `os.iso` file with our teeny kernel on it. You could
burn this to a USB stick or CD and run it on an actual computer if you wanted
to! But doing so would be really annoying during development. So in the next
section, we’ll use an emulator, QEMU, to run the ISO file on our development
machine.
