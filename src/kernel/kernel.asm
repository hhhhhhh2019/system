[org 500h]
[bits 32]

jmp start

%include "src/include/screen.asm"

start:
	push dword 24 ; row
	push 79 ; col
	push dword 0x4a
	push dword 'X'
	call print_char_at

	add esp, 4 * 4 ; restore stack

	push dword 0 ; row
	push dword 0 ; col
	push dword 0x0f ; attr
	push dword msg ; str
	call print_at

	add esp, 4 * 4 ; restore stack

jmp $


msg: db "Hello", 0