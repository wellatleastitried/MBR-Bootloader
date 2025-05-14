[bits 16]
[org 0x7C00]

start:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov si, boot_message
    call .print_loop

.halt:
    cli

.hang:
    hlt
    jmp .hang

.print_loop:
    lodsb
    cmp al, 0
    je .halt
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    jmp .print_loop

boot_message db 'First MBR Bootloader', 0
times 510-($-$$) db 0
dw 0xAA55
