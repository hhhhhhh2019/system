[org 500h]
[bits 32]

jmp start

%include "src/include/screen.asm"
%include "src/kernel/int.asm"
%include "src/include/keyboard.asm"

start:
	call init_keyboard

	call set_idt

	int 0h
jmp $


msg: db "Hello", 0
