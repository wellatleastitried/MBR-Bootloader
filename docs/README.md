# NASM/MBR Guide

This guide provides a comprehensive breakdown of the boot.asm file, which is used as an MBR bootloader.

## Header

```asm
[bits 16]
```

Tells NASM to emit 16-bit machine code. This is required because the BIOS uses 16-bit real mode, which only understands 16-bit opcodes and registers. This directly impacts instruction encoding, as different opcodes are emitted in 16-bit vs 32/64-bit modes.

```asm
[org 0x7C00]
```

Sets the origin of the program (where the code will actually reside in memory). The BIOS loads the MBR to the physical address `0x0000:0x7C00`. This also ensures that all labels resolve to correct addresses when the binary runs.

## Start Label

```asm
xor ax, ax
```

Clears the `ax` register (setting it to `0x0000`). This is a common way to zero a register while using fewer bytes than `mov ax, 0`.

```asm
mov ds, ax
mov es, ax
```

Now that the `ax` register has been zeroed, we can use it to set the `ds` (Data Segment) register and the `es` (Extra Segment) register. The `ds` register is used implicitly by instructions like `lodsb` that read from memory, `es` is not used in this program but it is good practice to set it when in real mode.

```asm
mov si, boot_message
```

Sets the `si` register (Source Index) to point to the `boot_message` string. `si` will be used with `lodsb`.

```asm
call .print_loop
```

This is a local label that is used as a jump target. It will loop until the string ends.

## Halt

```asm
cli
```

Clears the interrupt flag: disables hardware interrupts. This is a common practice before `hlt` to avoid interrupting thee halted CPU.

## Hang

```asm
hlt
```

Puts the CPU into a low-power stopped state until the next interrupt. Since we `cli`'d before this call, no interrupts can wake it, so it will just stop.

```asm
jmp .hang
```

Ensures the CPU stays in the halted state. This is a common practice in bootloaders to prevent the CPU from executing random code after the bootloader has finished.

## Print Loop

```asm
lodsb
```

This instruction loads the byte at `[ds:si]` into the `al` register and increments `si`. This is a convenient way to read a string one byte at a time.

```asm
cmp al, 0
```

Compares the value in `al` to `0x00`. Since the string we are printing is null-terminated, this will act as a check for the end of the string.

```asm
je .halt
```

(Jump if Equal) If the value in `al` is 0, jump to the `.halt` label. This is called at the end of the string, otherwise, continue printing.

```asm
mov ah, 0x0E
```

Prepares for a BIOS call: `INT 10h` (video interrupt), and function 0x0E (teletype output - prints the character in `al`). `ah` holds the function number.

```asm
mov bh, 0x00
```

Specifies the display page number. 0 is default and is almost always used for simple text output.

```asm
mov bl, 0x07
```

`bl` contains the text attribute (both foreground and background color). `0x07` is a light gray on black (which is a standard BIOS text color).

```asm
int 0x10
```

This is the BIOS interrupt call for video services. With `ah` set to `0x0E`, it will print the character is `al` to the screen.

```asm
jmp .print_loop
```

Jump back to the `.print_loop` label to print the next character in the string (or halt if the next character is the null-termination).

## String declaration

```asm
boot_message db 'First MBR Bootloader', 0
```

`db` (Define Bytes) is used to declare a string in memory. The string is followed by a null bytes to mark the end of the string. These bytes will live in the boot sector directly after this compiled program.

```asm
times 510-($-$$) db 0
```

This line ensures the boot sector is exactly 510 bytes (The total boot sector must be 512 bytes, but there needs to be space leftover for the final two bytes that are set in the following instruction). The expression `510-($-$$)` calculates how many bytes are left to fill. `$` is the current address, and `$$` is the start address of the section. `db` 0 tells the `times` instruction to fill the remaining space with zeroes.

```asm
dw 0xAA55
```

`dw` (Define Word: 2 bytes) writes the boot signature at the end of the boot sector. This is a required signature for BIOS to recognize the sector as a valid bootloader. The value `0xAA55` is a magic number that indicates the end of the boot sector (the total 512 bytes). In little-endian, this appears as Byte 510: `0x55`, Byte 511: `0xAA`. If these last two bytes are not present, BIOS will reject the boot sector.

