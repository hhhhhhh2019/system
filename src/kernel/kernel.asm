[org 500h]
[bits 32]

jmp start

%include "src/include/screen.asm"
%include "src/kernel/isr.asm"
%include "src/include/keyboard.asm"

start:
	call init_idt
	call keyboard_init

	sti
jmp $
