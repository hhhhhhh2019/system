[org 500h]
[bits 32]

jmp start

%include "src/include/screen.asm"

start:
	mov ebx, 0

loop:
	cmp ebx, 160 * MAX_ROWS
	je end

	push dword ebx
	call get_offset_row
	add esp, 1 * 4

	push dword eax

	push dword ebx
	call get_offset_col
	add esp, 1 * 4

	push dword eax

	push dword 0x4a
	push dword 'X'
	call print_char_at

	add esp, 4 * 4 ; restore stack

	add ebx, 2

	jmp loop

end:
jmp $


msg: db "Hello", 0