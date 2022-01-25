[org 0x1100]
[bits 32]


jmp start

%include "src/include/string.asm"
%include "src/kernel/isr.asm"
%include "src/include/keyboard.asm"
;%include "src/include/disk.asm"

start:
	call init_idt
	call keyboard_init
	;sti

	push dword MAX_COLS * MAX_ROWS * 2
	push dword 0x0f00
	push dword 0xb8000
	call memset_word
	add esp, 4 * 3
jmp $
