QEMU-FLAGS=


all: compile setup_fs
	qemu-system-i386 build/boot.img $(QEMU-FLAGS)

compile: boot.bin kernel.bin
	nasm src/disk.asm -o build/boot.img

	dd if=build/boot.bin of=build/boot.img bs=512 conv=notrunc seek=0
	dd if=build/kernel.bin of=build/boot.img bs=512 conv=notrunc seek=35

boot.bin: src/boot/boot.asm
	nasm $< -o build/$@

kernel.bin: src/kernel/kernel.asm
	nasm $< -o build/$@

setup_fs:
	python3.10 setup.py build/boot.img
