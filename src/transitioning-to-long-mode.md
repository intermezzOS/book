# Transitioning to Long Mode

We now have our little kernel in protected mode. But we’re making a 64-bit
kernel here, so we need to transition from protected mode to ‘long mode’.
This takes a sequence of steps. After this, the next step is calling into
Rust code!
