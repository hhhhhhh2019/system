QEMU-FLAGS=


all: boot.bin kernel.bin
	nasm src/disk.asm -o build/boot.img

	dd if=build/boot.bin of=build/boot.img bs=512 conv=notrunc seek=0
	dd if=build/kernel.bin of=build/boot.img bs=512 conv=notrunc seek=4

	qemu-system-i386 build/boot.img $(QEMU-FLAGS)

boot.bin: src/boot/boot.asm
	nasm $< -o build/$@

kernel.bin: src/kernel/kernel.asm
	nasm $< -o build/$@
