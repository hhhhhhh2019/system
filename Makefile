QEMU-FLAGS=


all: boot.img compile setup_fs
	qemu-system-i386 build/boot.img $(QEMU-FLAGS)

run:
	qemu-system-i386 build/boot.img $(QEMU-FLAGS)

update: compile run


compile: boot.bin start.bin kernel.bin
	dd if=build/boot.bin of=build/boot.img bs=512 conv=notrunc seek=0
	dd if=build/start.bin of=build/boot.img bs=512 conv=notrunc seek=34

boot.img: src/disk.asm
	nasm $< -o build/$@

boot.bin: src/boot/boot.asm
	nasm $< -o build/$@

start.bin: src/boot/start.asm
	nasm $< -o build/$@

kernel.bin: src/kernel/kernel.asm
	nasm $< -o build/$@

setup_fs:
	python3.10 setup.py build/boot.img
