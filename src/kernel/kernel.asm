[org 0x1100]
[bits 32]

jmp start

%include "src/include/screen.asm"
%include "src/kernel/isr.asm"
;%include "src/include/keyboard.asm"
;%include "src/include/timer.asm"
%include "src/include/disk.asm"


start:
	call init_idt

	sti

	push dword msg
	push dword 1
	push dword 2
	call read_sector
	add esp, 4 * 3

	push dword 0
	push dword 0
	push dword 0x0f
	push dword msg
	call print_at
	add esp, 4 * 4
jmp $

boot_disk: dw 0

msg: times 512 db '0'
