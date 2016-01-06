# Numeral Systems

In mathematics there exists different **numeral systems** with different bases, we commonly use the numeral system with base 10, also known as the **decimal system**. It uses the digits \\( \\{0, 1, 2, 3, 4, 5, 6, 7, 8, 9\\} \\). Other common numeral systems include **binary** \\( \\{0, 1\\} \\), **octal** \\( \\{0, 1, 2, 3, 4, 5, 6, 7\\} \\) and **hexadecimal** \\( \\{0, 1, 2, 3, 4, 5, 6, 7, 8, 9, a, b, c, d, e, f\\} \\).

As you can see, the base indicates how many digits the system contains.

## Decimal system
Before we explain the binary and hexadecimal system, let's start with a numeral system we are more familiar with, the decimal system.

To express values between `0` and `9` in the decimal system, it's very easy, we can just use the corresponding digits.
But when we want to express values higher than `9` we have to use a combination of the base digits.

The value `10`, for example is represented by a combination of the digits "1" and "0". In this case the "1" indicates you have already counted one time through all the digits of the numeral system, which is equal to the base.

\\[ 1 \cdot 10^1 + 0 \cdot 10^0 = 10 \\]


If we count once again trough all the digits of the system we would have counted a number of elements equal to *two times the base*
(\\( 2 \cdot 10^1 = 20\\))

### Example with value `120`

The value `120` has a `0` at position zero, a `2` at position one and a `1` at position two.

- The `1` at position two means you have counted *one time ten (base) times all the digits (base)* or
    \\[ 1\cdot base \cdot base = 1 \cdot base^2 = 1 \cdot 10^2 = 100 \\]
    When writing it as a power of the base, we can see the relation between the position of the digit and the power of the base.

- The `2` at position one means you have counted *two times all the digits (base)* or
    \\[ 2 \cdot base = 2 \cdot base^1 =  2 * 10^1 = 20 \\]

- The `0` at position zero means you have counted *zero elements* or
    \\[ 0 = 0 \cdot base^0 = 0 \cdot 10^0 = 0 \cdot 1 = 0 \\]

When we add all that up we obtain

\\[ 1 \cdot base^2 + 2 \cdot base^1 + 0 \cdot base^0 = 1 \cdot 10^2 +  2 \cdot 10^1 + 0 \cdot 10^0 = 100 + 20 + 0 = 120 \\]

As you can see, it does not make a lot of sense to do this calculation for the decimal system as a decimal value converted to a decimal value will remain the same obviously. It will however make more sense for other numeral systems.


## Binary system
Binary has a base of two and works exactly the same.
When we have the binary number `10` we have counted *once trough all the digits of the system* \\( \\{0, 1\\} \\) so we have a value equivalent to `2` in the decimal system:

\\[ 1 \cdot base^1 + 0 \cdot base^0 = 1 * 2^1 + 0 * 2^0 = 2 \\]

The binary value `100` means we have counted *one time two (base) times through all the digits (base)*, which would equal to `4` in decimal.

\\[1 \cdot base^2 + 0 \cdot base^1 + 0 \cdot base^0 = 1 \cdot 2^2 + 0 \cdot 2^1 + 0 \cdot 2^0 = 4 \\]

Let's do one more, the binary value `1010` means we have counted *one time two (base) times two (base) times two (base) digits* and *one time two (base) times two (base) digits*.

\\[ 1 \cdot base^3 + 0 \cdot base ^2 + 1 \cdot base^1 + 0 \cdot base^0 = 1 \cdot 2^3 + 0 \cdot 2^2 + 1 \cdot 2^1 + 0 \cdot 2^0 = 8 + 2 = 10\\]

## Hexadecimal System
Hexadecimal is the same thing again with base sixteen with the exception that our language only has 10 symbols to represent digits, therefore we use the letters `a` through `f` to represent the missing digits. We could have chosen any other symbol really.

So `a` in hexadecimal is equivalent to `10` in decimal, `b` equal to `11`, etc.

The hexadecimal value `10` does again mean we have counted *through all the digits of the system once*, this would be equivalent to `16` in decimal.

Let's do this one more time with a more exotic hexadecimal value: `3e8`. This value means we have counted *three times sixteen (base) times  all the digits of the system (base)* and *`e` times, which is equal to decimal 14, all digits (base)* and *8 remaining elements*.

\\[ 3 \cdot base^2 + e \cdot base^1 + 8 \cdot base^0 = 3 \cdot 16^2 + 14 \cdot 16^1 + 8 \cdot 16^0 = 768 + 224 + 8 = 1000 \\]

## Converting from decimal to another base
Until now, we have only converted values from a numeral system with a specific base to the decimal system. But what if we want to do the opposite?

For this we are going to use the **divison** and **remainders**

Let's say we have the value `2344` and want to convert it into hexadecimal. We are going to divide the value by the base we want to convert to. The remainder of this operation will be our first digit (at position zero) and we are going to repeat this operation with the result of the (integer) division.

\\[ \begin{array}
        {lcr} 16 & | & 2344
        \\\\ && 146 & rem & 8
        \\\\ && 9 & rem & 2
        \\\\ && 0 & rem & 9
    \end{array}
\\]

Remember the first remainder is the digit at the first position, position zero! So the converted number reads from bottom up: `928`. We can double check that this is correct by converting the hexadecimal result back into decimal using the power rule.

\\[ 9 \cdot 16^2 + 2 \cdot 16^1 + 8 \cdot 16^0 = 2344 \\]

Let's do one more hexadecimal number before we try some binary numbers. The value we are going to convert from decimal to hexadecimal is `43981`.

\\[ \begin{array}
        {lcr} 16 & | & 43981
        \\\\ && 2748 & rem & 13 = d
        \\\\ && 171 & rem & 12 = c
        \\\\ && 10 & rem & 11 = b
        \\\\ && 0 & rem & 10 = a
    \end{array}
\\]

The decimal value `43981` corresponds thus to the hexadecimal value `abcd`

Let's try the same for binary numbers now, if we want to convert the decimal value `41` to binary:

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
In this chapter we have learned there were an infinite amount of numeral systems beside the decimal system we use in our every day life.
We have seen why the hexadecimal system uses the letters `a` through `f` and finally we have learned how to convert back and forth between any numeral system and the decimal system.
