[org 500h]
[bits 32]

jmp start

%include "src/include/screen.asm"

msg: db "Hello", 0
null: dd 0

start:
	push 2 ; row
	push 10 ; col
	push dword 0x0f ; attr
	push msg ; str
	call print_at
	pop dword [null]
	pop dword [null]
	pop dword [null]
	pop dword [null]

jmp $