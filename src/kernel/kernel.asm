[org 500h]
[bits 32]

jmp start

%include "src/include/screen.asm"

msg: db "Hello", 0
null: dd 0

start:
	push dword 0x0f
	push msg
	call print_char
	pop dword [null]
	pop dword [null]

jmp $