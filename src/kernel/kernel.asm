[org 500h]
[bits 32]

jmp start

%include "src/include/screen.asm"

start:
	mov ebx, 0

loop:
	cmp ebx, 320
	je end

	push ebx
	call get_offset_row
	add esp, 4

	push eax

	push ebx
	call get_offset_col
	add esp, 4

	push eax

	push 0x0f
	push 'X'

	call print_char_at
	add esp, 4 * 4 ; restore stack

	mov ebx, eax
jmp loop

end:
jmp $


msg: db "Hello", 0
