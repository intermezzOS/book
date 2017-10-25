# Windows

# Windows 10

If you're using Windows 10, you can use [Bash On Ubuntu on
Windows](https://msdn.microsoft.com/en-us/commandline/wsl/about) to get
going in an easy way.

Once you have installed Bash on Ubuntu on Windows, simply follow the [Linux
instructions](linux.html). You'll also need the `grub-pc-bin` package.

Finally, you'll need an "X server"; this will let us run intermezzOS in a
graphical window. Any will do, but we've tried
[xming](https://sourceforge.net/projects/xming/) and it works well.

Finally, you'll need to run this:

```bash
$ export DISPLAY=:0
```

You can put it in your `~/.bashrc` file to have it automatically work on each
session.

## Other Windows Versions

I hope to have better instructions for Windows soon; since I don’t have a
computer that runs it, I need to figure it out first. If you know how, this
would be a great way to [contribute](https://github.com/intermezzOS/book).
