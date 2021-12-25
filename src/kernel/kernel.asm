[org 500h]
[bits 32]

jmp start

%include "src/include/screen.asm"

start:
	push 3 		; y
	push 4 		; x
	push 0x0f ; attr
	push msg 	; str
	call print_at
	add esp, 4 * 4

	push dword 0
	push dword 0
	call set_cursor_pos
	add esp, 8

jmp $


msg: db "Hello", 0
