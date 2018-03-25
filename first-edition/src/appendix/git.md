# Appendix C: Version control

Some early computer games had no means of saving your progress. So when you
painstakingly dodged spears, evaded boulders, jumped crevasses and made a
mistake, you had to start all over again. Saving your progress makes playing
games easier. Version control is like saving your progress for projects.

In this appendix we will cover git and how you can use it keep track of changes
in your project.

## Installing `git`

We use the version control system [`git`][git]. In this section you can find
details on how to set up git for your system.

### Linux

On a Debian based Linux distribution you can install `git` with the following
command:

```sh
$ sudo apt-get install git
```

### Mac OS X

There is a binary installer for `git` that can be found at
[http://git-scm.com/download/mac](http://git-scm.com/download/mac).

### Windows

I hope to provide better instructions for windows soon. If you know how consider
[contributing][] to the book.

## Starting

git can keep track of changes to your project. To get started with tracking your
project you need to initialize git. In the root of your directory execute the
command

```sh
$ git init
```

This asks the git to start a repository that will track changes to your project.

## Status

With the previous command you created a repository. But git is not tracking anything
yet! Issue the next command to see what git knows about your project.

```sh
$ git status
```

This will give the following output.

```text
On branch master

Initial commit

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	Makefile
	boot.asm
	build/
	grub.cfg
	linker.ld
	multiboot_header.asm

nothing added to commit but untracked files present (use "git add" to track)
```

One important section is the `untracked files` section. Here git lists the files
that are not tracked yet. You can recognize the files that you created for
intermezzOS.

## Ignoring

Some files do not need to be tracked by git. For example, the build directory
can be recreated by running the `make` command. We can instruct git to ignore
certain files.

You can do this by creating a file `.gitignore` and adding the `build/`
directory.

```sh
$ touch .gitignore
```

With the content

```text
build
```

The `git status` command now does not list `build/` anymore. Instead is lists
the newly created `.gitignore` file.

## Adding

If you want git to keep track of changes to your project you need to tell which
files you are interested in. You can do this with the `add` command. For example
the following command adds the `Makefile`

```sh
$ git add Makefile
```

If you issue the `git status` command again you see a change in the output.

```text
On branch master

Initial commit

Changes to be committed:
  (use "git rm --cached <file>..." to unstage)

	new file:   Makefile

Untracked files:
  (use "git add <file>..." to include in what will be committed)

	.gitignore
    boot.asm
	grub.cfg
	linker.ld
	multiboot_header.asm

```

We will use the `git add` command again to add the other files that we want git
to track.

```sh
$ git add .gitignore boot.asm grub.cfg linker.ld multiboot_header.asm
```

## Commiting

We added files to git's staging area. The staging area is used to create a nice
commit. A commit is like a save point. Ideally you want a commit to be something
you can go back to safely.

Once you are happy with the files in the staging area you can commit them with
the following command.

```sh
$ git commit
```

An editor will open so you can provide a _commit message_, a description of the
commit that will help in identifying what changed. For example,

```text
A minimal OS that outputs "Hello, World!"
```

## Rinse and Repeat

Using git revolves around the staging and commiting cycle. Once you have created
an interesting change, stage it with the `git add` command. If you are content
with the staged changes commit it with `git commit` and the cycle starts over
again.

For example, if you would create a `README.md` file that describes your project,
you could add

```sh
$ git add README.md
```

Because it is the only thing we changed in our we can continue to commit it.

```sh
$ git commit -m "Described project in a README"
```

The `-m` options allows you to write the commit message inline instead of going
to your editor.

## Reference

Git is a comprehensive version control system and we only scratched the surface.
If you want to learn more follow any of the following references.

* [https://try.github.io](https://try.github.io) for a short high-level
explanation 
* [http://gitimmersion.com/](http://gitimmersion.com/) for all of that, and more
advanced concepts (also a longer tutorial)

[git]: https://git-scm.com/
[contributing]: https://github.com/intermezzOS/book
