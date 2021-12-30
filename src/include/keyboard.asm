%ifndef KEYBOARD
%define KEYBOARD

%include "src/kernel/int.asm"


keyboard_int:
	push dword 5
	push dword 4
	call get_offset
	add esp, 4 * 2

	push eax
	call set_cursor_pos
	add esp, 4
iret


init_keyboard:
	push ecx

	mov ecx, 0

init_keyboard_loop:
	cmp ecx, 47
	je init_keyboard_end

	push dword keyboard_int
	push dword ecx
	call set_idt_gate
	add esp, 4 * 2

	inc ecx

jmp init_keyboard_loop

init_keyboard_end:
	pop ecx
ret


%endif
