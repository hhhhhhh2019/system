QEMU-FLAGS=


all: boot.bin kernel.bin
	nasm src/disk.asm -o build/boot.img

	dd if=build/boot.bin of=build/boot.img conv=notrunc bs=512 seek=0
	dd if=build/kernel.bin of=build/boot.img conv=notrunc bs=512 seek=4

	qemu-system-x86_64 build/boot.img $(QEMU-FLAGS)

boot.bin: src/boot/boot.asm
	nasm $< -o build/$@

kernelStart.o: src/kernel/kernel_start.asm
	nasm $< -f elf32 -o build/$@

screen.o: src/include/screen.c
	gcc -ffreestanding -c $< -o build/$@ -m32 -fno-pie

kernel.o: src/kernel/kernel.c
	gcc -ffreestanding -c $< -o build/$@ -I "src/include" -m32 -fno-pie

kernel.bin: src/kernel/kernel.asm
	#ld -o build/$@ -Ttext 0x500 $(foreach wrd,$^,build/$(wrd)) -m elf_i386
	#objcopy -O binary -j .text build/$@ build/$@
	nasm $< -o build/$@
