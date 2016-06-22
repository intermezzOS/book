# Mac OS X

The tools you need are similar to the tools listed in the [Linux
instructions](linux.html), but we will need to build a cross compiler in
order to get things working. This is sort of complicated and boring, but we've
done some of that boring work for you so you can get up and running quickly.

Make sure you have [homebrew](http://brew.sh/) installed because you are going
to need it to install some of the tools. You are probably also going to need
[Xcode](https://developer.apple.com/xcode/download/) if you don't already have
it. You _may_ have to agree to the Xcode license before you use it. You can do
this by either opening Xcode and accepting the license agreement, or by running
`sudo xcodebuild -license` in the terminal, scrolling down to the bottom of the
license, and agreeing to it.

Download [this script] and *read* through it. There are a couple assumptions
that it makes about the paths where the source is downloaded to and where the
binaries are installed.  You might want to change where those locations are.
When possible we try and use `brew` to install things, but there are some
programs we need to compile.  The compiled special versions of the tools are
installed in `~/opt`. This is so we don't clobber any version of them that you
may have already installed. The source code for these tools are downloaded in
`~/src`.

[this script]: appendix/osx-install.html

Here is what the script does:

1. `brew install` tools that it can like `gmp`, `mpfr`, `libmpc`, `autoconf`, and `automake`
2. Download and compile tools in order to make a cross compiler: `binutils`, `gcc`, `objconv`
3. Download and compile `grub` using the cross compiler

This might take some time to run.

After it is done you should have all the tools you need located in `~/opt`. The
tools _should_ be named the same as the tools used in other chapters, but they
might be prefixed with a `x86_64-pc-elf-`. The exception to this is `grub`. The
default path for the binaries installed using the above script is `$HOME/opt/bin` so adjust the PATH variable appropriately.