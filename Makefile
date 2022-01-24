QEMU-FLAGS=
dd-flags = conv=notrunc


all: boot.img compile setup_fs
	qemu-system-i386 build/boot.img $(QEMU-FLAGS)

run:
	qemu-system-i386 build/boot.img $(QEMU-FLAGS)

update: compile run

update_all: compile update_kernel run


compile: boot.bin start.bin kernel.bin
	dd if=build/boot.bin of=build/boot.img bs=512 $(dd-flags) seek=0
	dd if=build/start.bin of=build/boot.img bs=512 $(dd-flags) seek=34

update_kernel:
	dd if=build/kernel.bin of=build/boot.img bs=512 $(dd-flags) seek=79

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
