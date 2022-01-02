%ifndef KEYBOARD
%define KEYBOARD

%include "src/kernel/int.asm"


%define ESC 0x01
%define BACKSPACE 0x0e
%define TAB 0x0f
%define ENTER 0x1c
%define LCTRL 0x1d
%define LSHIFT 0x2a
%define RSHIFT 0x36
%define KEYPAD 0x37
%define LALT 0x38
%define SPACE 0x39


keyboard_map:
db 0, 1
db '1234567890-=', BACKSPACE
db TAB, 'QWERTYUIOP[]', ENTER, LCTRL, 'ASDFGHJKL;', "'", '`', LSHIFT, '\ZXCVBNM,./', RSHIFT, KEYPAD, LALT, SPACE


keyboard_int:
	push dword 0x64
	call get_port_byte
	add esp, 4
	and eax, 0x01

	cmp eax, 1
	je keyboard_int_continue

	jmp keyboard_int_end



keyboard_int_continue:
	push ebx
	push ecx

	call get_cursor_pos
	mov ebx, eax

	push dword 0x60
	call get_port_byte
	add esp, 4

	mov byte cl, [keyboard_map + eax]

	cmp eax, 0x80
	jl keyboard_int_keydown

	jmp keyboard_int_keyup

keyboard_int_keydown:
	push ebp
	mov ebp, VIDEO_ADDRESS
	mov byte [ebp + ebx], cl
	mov byte [ebp + ebx + 1], 0x0f
	pop ebp

	add ebx, 2

	push ebx
	call set_cursor_pos
	add esp, 4

	jmp keyboard_int_end


keyboard_int_keyup:



keyboard_int_end:
	push dword 0xA0
	push dword 0x20
	call set_port_byte
	add esp, 4 * 2

	push dword 0x20
	push dword 0x20
	call set_port_byte
	add esp, 4 * 2

	pop ecx
	pop ebx
iret


keyboard_init:
	push dword keyboard_int
	push dword 33
	call set_idt_gate
	add esp, 4 * 2

	push dword 0xfd
	push dword PIC1 + 1
	call set_port_byte
	add esp, 4 * 2
ret


%endif
