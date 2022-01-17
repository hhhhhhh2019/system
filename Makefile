QEMU-FLAGS=


all: compile setup_fs
	qemu-system-i386 build/boot.img $(QEMU-FLAGS)

compile: boot.bin start.bin kernel.bin
	nasm src/disk.asm -o build/boot.img

	dd if=build/boot.bin of=build/boot.img bs=512 seek=0
	dd if=build/start.bin of=build/boot.img bs=512 seek=34

boot.bin: src/boot/boot.asm
	nasm $< -o build/$@

start.bin: src/boot/start.asm
	nasm $< -o build/$@

kernel.bin: src/kernel/kernel.asm
	nasm $< -o build/$@

setup_fs:
	python setup.py build/boot.img
