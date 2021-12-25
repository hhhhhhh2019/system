[org 500h]
[bits 32]

jmp start

%include "src/include/screen.asm"

start:
	push 10
	push 12
	push 0x0f
	push msg
	call print_at
	add esp, 4 * 4

jmp $


msg: db "Hello", 0
