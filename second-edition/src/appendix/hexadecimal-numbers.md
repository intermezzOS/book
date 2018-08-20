# Appendix B: hexadecimal numbers

This is a work in progress, and isn't ready to read yet!

If we were to write this all in decimal:

| name | value |
|------|-------|
| Black | `0` |
| Blue | `1` |
| Green | `2` |
| Cyan | `3` |
| Red | `4` |
| Magenta | `5` |
| Brown | `6` |
| Gray | `7` |
| DarkGray | `8` |
| BrightBlue | `9` |
| BrightGreen | `10` |
| BrightCyan | `11` |
| BrightRed | `12` |
| BrightMagenta | `13` |
| Yellow | `14` |
| White | `15` |

The code becomes:

```rust
slice[1] = 2;
```

This will work just as well, but we've lost that `0` to let us know that we
have black. Furthermore, let's take a look at a more complex version:

```rust
slice[1] = 0xFA; // White background, BrightGreen foreground

slice[1] = 250;
```

`0xFA` in hexadecimal is `250` in decimal, and it completely loses all of the
meaning. We'd have to do the math ourselves to figure out what the color is.
Much easier to write it in hexadecimal in the first place.
