[org 500h]
[bits 32]

jmp start

%include "src/include/screen.asm"

start:
	push dword 0x0f ; attr
	push dword msg 	; str
	call print
	add esp, 4 * 4

	push dword 2
	push dword 0
	push dword 0x4a
	push dword 'X'
	call print_char_at
	add esp, 4 * 4

	;call scroll_screen

jmp $


msg: db "Hello", 0
