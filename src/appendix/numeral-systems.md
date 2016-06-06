# Numeral Systems

In math we use a particular **numeral system** to denote a particular number. A
numeral system is defined by the particular symbols it uses to convey numbers.

Below we'll examine three numeral systems: decimal, binary and hexadecimal.

## Decimal System

The numeral system you're probably most familiar with is the **decimal system**.
The symbols (or "digits") used in decimal are: `0`, `1`, `2`, `3`, `4`, `5`,
`6`, `7`, `8`, and `9`.

Decimal gets its name from the amount of unique symbols it uses to convey
numbers: ten. It makes sense that we would gravitate to a system with ten
unique symbols. After all, we typically have ten fingers (and ten toes).

The amount of unique symbols a numeral system uses is known as the "base" of that system
(and is less often called a "radix").

Decimal is also a "positional" numeral system. Once we run out of symbols, we
begin a new "order of magnitude" over with the same symbols. For example, after
`9` comes `10`. We recycle the `1` and `0` symbols to express that we've cycled
through the number `1` times. When we reach `20`, we want to say we've cycled
though `2` times. We start new cycles at a regular interval - every time we've
cycled through all the symbols of the digit furthest to the left.

If you're familiar with Roman numerals, you know that that system did not work
that way. "Orders of magnitude" don't start and stop at regular intervals.

### Let's Count

At the risk of taking things too slow, let's count in decimal the number of `|`s here:

`||||||||||||`

Let's begin with zero and go higher:

`0`, `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9` ...

Ok we're at nine, and we've run out of symbols. No worries. We add a `1` to the
beginning to say we've already gone through one cycle of numbers, and we start
over.

... `10`, `11`, `12`

Sorry if that was a bit too easy. You're probably pretty good with the decimal
system already so this wasn't too big of a challenge. But we'll do the same
exercise with other numeral systems to get a better feel for them.

### Let's Use Math

We can summarize what we just said with a math formula:

\\[ 1 \cdot 10^1 + 2 \cdot 10^0 = 12 \\]

Here we've written out that we've cycled completely through the numbers once
and then gotten through two symbols of the next cycle.

The value `120` has a `0` at position zero, a `2` at position one and a `1` at position two.

- The `1` at position two means you have counted "one" times "ten" (a.k.a the base)
  times all the digits (a.k.a the base) or
    \\[ 1\cdot base \cdot base = 1 \cdot base^2 = 1 \cdot 10^2 = 100 \\]
    When writing it as a power of the base, we can see the relation between the
    position of the digit and the power of the base.

- The `2` at position one means you have counted *two times all the digits (a.k.a the base)* or
    \\[ 2 \cdot base = 2 \cdot base^1 =  2 * 10^1 = 20 \\]

- The `0` at position zero means you have counted *zero elements* or
    \\[ 0 = 0 \cdot base^0 = 0 \cdot 10^0 = 0 \cdot 1 = 0 \\]

When we add all that up we obtain

\\[ 1 \cdot base^2 + 2 \cdot base^1 + 0 \cdot base^0 = 1 \cdot 10^2 +  2 \cdot 10^1 + 0 \cdot 10^0 = 100 + 20 + 0 = 120 \\]

Congrats! You've successfully converted a decimal value back into decimal - a
feat that probably seems utterly useless but will come in very handy when we
want to convert from some other numeral system to decimal.

Now we'll examine two new numeral systems. The are positional just like decimal, but
have different bases. We'll examine **binary** with a base of two, and **hexadecimal**
with a base of sixteen.

## Binary system

Unlike decimal's base of ten, binary has a base of two. Meaning we only have two
symbols to work with to represent all the numbers: `0`, `1`. Say
goodbye to `3`, `4`, `5`, `6`, `7`, `8`, and `9`. We can't use them.

So when we have the binary number `10` we don't have the number ten. What we've really
done is counted *once through all the digits of the system* `0`, `1` and
started again. So we have the number two.

### Let's Count

Let's count `|` again, but this time in binary:

`|||||||`

If we were counting in decimal we would use the symbol `7` to refer to this
number. Let's start at zero:

`0`, `1` ...

Hopefully you weren't tempted to go to `2` next! That's right, we've already
made a full round trip, so let's start over.

... `10`, `11`, `100`, `101`, `110`, `111`

We've successfully counted to the number seven using binary!

### Let's Use Math

The binary value `100` means we have counted *one times two (a.k.a the base) times
through all the digits (a.k.a. the base)*, which would equal to `4` in decimal.

\\[1 \cdot base^2 + 0 \cdot base^1 + 0 \cdot base^0 = 1 \cdot 2^2 + 0 \cdot 2^1 + 0 \cdot 2^0 = 4 \\]

Let's do one more, the binary value `1010` means we have counted *one times two
(a.k.a the base) times two (a.k.a the base) times two (a.k.a the base) digits*
and *one times two (a.k.a the base) times two (a.k.a the base) digits*.

\\[ 1 \cdot base^3 + 0 \cdot base ^2 + 1 \cdot base^1 + 0 \cdot base^0 = 1 \cdot 2^3 + 0 \cdot 2^2 + 1 \cdot 2^1 + 0 \cdot 2^0 = 8 + 2 = 10\\]

Hurray! We've successfully converted binary to decimal!

## Hexadecimal System

And now we meet hexadecimal with a base of sixteen. Before we begin we have to answer the
question of how we represent sixteen unique digits when we're used to representing only ten.

To represent the digits after `9` until a new cycle begins we'll use the letters
`a` through `f`. This is arbitrary and we could have chosen any other symbol really.
But then again it's all arbitrary. We could, for example, use the symbol `}` to represent
one, but we chose `1` instead.

So `a` in hexadecimal is equivalent to `10` in decimal, `b` equal to `11`, etc.

The value `10` does exist in hexadecimal. It means, once again, we have counted
*through all the digits of the system once* and are starting the cycle again.
However, instead of it being ten, it's sixteen. Another way of thinking about
this is `10` in hexadecimal is equal to `16` in decimal.

### Let's Count

Once again, let's count `|`s but this time using hexadecimal notation:

`||||||||||||||||||||`

If we were using decimal we would use the symbol `20` to refer to this number.
Let's start again at zero:

`0`, `1`, `2`, `3`, `4`, `5`, `6`, `7`, `8`, `9` ...

Don't be tempted to do the decimal thing and use `10`!

... `a`, `b`, `c`, `d`, `e`, `f`, `10`, `11`, `12`, `13`, `14`

Congrats! You've counted to twenty in hexadecimal!

### Let's Use Math

Let's do the math thing one more time with an exotic hexadecimal value: `3e8`.
This value means we have counted *three times sixteen (a.k.a the base) times all the
digits of the system (a.k.a the base)* and *`e` times, which is equal to 14 in decimal,
all digits (a.k.a the base)* and *8 remaining elements*.

\\[ 3 \cdot base^2 + e \cdot base^1 + 8 \cdot base^0 = 3 \cdot 16^2 + 14 \cdot 16^1 + 8 \cdot 16^0 = 768 + 224 + 8 = 1000 \\]

## Converting From Decimal to Another Base

Until now, we have only converted values from a numeral system with a specific base
to the decimal system. But what if we want to do the opposite?

For this we are going to use the **divison** and **remainders**

Let's say we have the value `2344` and want to convert it into hexadecimal.
We are going to divide the value by the base we want to convert to. The remainder
of this operation will be our first digit (at position zero) and we are going to
repeat this operation with the result of the (integer) division.

\\[ \begin{array}
        {lcr} 16 & | & 2344
        \\\\ && 146 & rem & 8
        \\\\ && 9 & rem & 2
        \\\\ && 0 & rem & 9
    \end{array}
\\]

Remember the first remainder is the digit at the first position, position zero!
So the converted number reads from bottom up: `928`. We can double check that this
is correct by converting the hexadecimal result back into decimal using the power rule.

\\[ 9 \cdot 16^2 + 2 \cdot 16^1 + 8 \cdot 16^0 = 2344 \\]

Let's do one more hexadecimal number before we try some binary numbers.
The value we are going to convert from decimal to hexadecimal is `43981`.

\\[ \begin{array}
        {lcr} 16 & | & 43981
        \\\\ && 2748 & rem & 13 = d
        \\\\ && 171 & rem & 12 = c
        \\\\ && 10 & rem & 11 = b
        \\\\ && 0 & rem & 10 = a
    \end{array}
\\]

The decimal value `43981` corresponds thus to the hexadecimal value `abcd`

Let's try the same for binary numbers now, if we want to convert the decimal value
`41` to binary:

\\[ \begin{array}
        {lcr} 2 & | & 41
        \\\\ && 20 & rem & 1
        \\\\ && 10 & rem & 0
        \\\\ && 5 & rem & 0
        \\\\ && 2 & rem & 1
        \\\\ && 1 & rem & 0
        \\\\ && 0 & rem & 1
    \end{array}
\\]

We get the binary number `101001`, let's check:

\\[ 1 \cdot 2^5 + 0 \cdot 2^4 + 1 \cdot 2^3 + 0 \cdot 2^2 + 0 \cdot 2^1 + 1 \cdot 2^0 = 41 \\]

Fantastic, it worked once again!

## Conclusion

In this chapter we have learned there were many numeral systems beside the decimal
system we use in our every day life. We've seen why the hexadecimal system uses the
letters `a` through `f` and finally we have learned how to convert back and forth
between any numeral system and the decimal system.
