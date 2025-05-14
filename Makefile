
OUTPUT = build/boot.bin
ASM = src/boot.asm

all: $(OUTPUT)

$(OUTPUT): $(ASM)
	nasm -f bin -o $(OUTPUT) $(ASM)

run: $(OUTPUT)
	qemu-system-x86_64 -drive format=raw,file=$(OUTPUT)

clean:
	rm -f $(OUTPUT)
