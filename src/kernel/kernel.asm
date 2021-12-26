[org 500h]
[bits 32]

jmp start

%include "src/include/screen.asm"

start:
	push dword 3 ; row
	push dword 10 ; col
	call get_offset
	add esp, 4 * 2

	push dword eax ; offset
	call set_cursor_pos
	add esp, 4 * 1


	push dword 0x0f ; attr
	push dword msg 	; str
	call print
	add esp, 4 * 4

	mov byte [VIDEO_ADDERS + 25 * 80 * 2 - 2], 'X'
	mov byte [VIDEO_ADDERS + 25 * 80 * 2 - 1], 0x4a

jmp $


msg: db "Hello", 0
