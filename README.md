# MBR-Bootloader

A minimalist x86 bootloader that prints a message from the Master Boot Record (MBR). This bootloader fits within 512 bytes and demonstrates how to initialize registers, print a string via BIOS interrupts, and safely halt the CPU. This was done as a learning experience, if you notice any issue with the x86, please open an issue!

## Overview

This project serves as a foundational step into low-level and systems programming using 16-bit real mode x86 assembly. It provides a fully working example of:
- Writing a valid MBR boot sector
- Using BIOS interrupt `0x10` for TTY output
- Initializing segment registers manually
- Embedding null-terminated strings

For a line-by-line breakdown of the code, see [here](docs/guide.md).

## Requirements

To build and run this bootloader, you will need:
- nasm (Netwide Assembler)
- qemu-system-x86_64 (or any other x86 emulator for testing)

## Installation

1. Clone the repository and initialize the build directory:
   ```bash
    git clone https://github.com/wellatleastitried/MBR-Bootloader.git
    cd MBR-Bootloader && mkdir build
    ```
2. Build the bootloader and run it with QEMU:
   ```bash
   make run
   ```
   **OR** only build the bootloader:
    ```bash
    make
    ```
3. To clean up the build files, run:
   ```bash
   make clean
   ```
