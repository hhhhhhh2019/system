[org 500h]
[bits 32]

jmp start

%include "src/kernel/isr.asm"

start:
	call isr_install

	push dword 4
	push dword 8
	call get_offset
	add esp, 4 * 2

	push eax
	call set_cursor_pos
	add esp, 4

	push dword 0x0f ; attr
	push dword msg 	; str
	call print
	add esp, 4 * 4
jmp $


msg: db "Hello", 0
