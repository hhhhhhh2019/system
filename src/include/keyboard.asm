%ifndef KEYBOARD
%define KEYBOARD

%include "src/kernel/int.asm"


%define ERROR 0x0

%define NUM_1 0x02
%define NUM_2 0x03
%define NUM_3 0x04
%define NUM_4 0x05
%define NUM_5 0x06
%define NUM_6 0x07
%define NUM_7 0x08
%define NUM_8 0x09
%define NUM_9 0x0a
%define NUM_0 0x0b

%define CHAR_Q 0x10
%define CHAR_W 0x11
%define CHAR_E 0x12
%define CHAR_R 0x13
%define CHAR_T 0x14
%define CHAR_Y 0x15
%define CHAR_U 0x16
%define CHAR_I 0x17
%define CHAR_O 0x18
%define CHAR_P 0x19
%define CHAR_A 0x1e
%define CHAR_S 0x1f
%define CHAR_D 0x20
%define CHAR_F 0x21
%define CHAR_G 0x22
%define CHAR_H 0x23
%define CHAR_J 0x24
%define CHAR_K 0x25
%define CHAR_L 0x26
%define CHAR_Z 0x2c
%define CHAR_X 0x2d
%define CHAR_C 0x2e
%define CHAR_V 0x2f
%define CHAR_B 0x30
%define CHAR_N 0x31
%define CHAR_M 0x32

%define F1 0x3b
%define F2 0x3c
%define F3 0x3d
%define F4 0x3e
%define F5 0x3f
%define F6 0x40
%define F7 0x41
%define F8 0x42
%define F9 0x43
%define F10 0x44
%define F11 0x57
%define F12 0x58

%define CHAR_- 0x0c
%define CHAR_= 0x0d
%define CHAR_[ 0x1b
%define CHAR_] 0x1c
%define CHAR_: 0x27
%define CHAR_' 0x28
%define CHAR_` 0x29
%define CHAR_\ 0x2b
%define CHAR_, 0x33
%define CHAR_. 0x34
%define CHAR_/ 0x35

%define KEYPAD 0x37

%define KEYPAD_NUM_7 0x47
%define KEYPAD_NUM_8 0x48
%define KEYPAD_NUM_9 0x49
%define KEYPAD_NUM_4 0x4b
%define KEYPAD_NUM_5 0x4c
%define KEYPAD_NUM_6 0x4d
%define KEYPAD_NUM_1 0x4f
%define KEYPAD_NUM_2 0x50
%define KEYPAD_NUM_3 0x51
%define KEYPAD_NUM_0 0x52

%define KEYPAD_CHAR_- 0x4a
%define KEYPAD_CHAR_+ 0x4e
%define KEYPAD_CHAR_. 0x53

%define ESCAPE 0x01
%define ENTER 0x1c
%define BACKSPACE 0x0e
%define LSHIFT 0x2a
%define RSHIFT 0x36
%define CTRL 0x1d
%define ALT 0x38
%define SPACE 0x39

%define CAPSLOCK 0x3a
%define NUMLOCK 0x45
%define SCROLLLOCK 0x46


last_key: db 0
last_key_down: db 0
last_key_up: db 0
last_state: db 0 ; up / down
key_update: db 0 ; false / true


keyboard_int:
	push dword 0x64
	call get_port_byte
	add esp, 4
	and eax, 0x01

	cmp eax, 1
	je keyboard_int_continue

	jmp keyboard_int_end


keyboard_int_continue:
	push ecx

	push dword 0x60
	call get_port_byte
	add esp, 4

	mov byte [last_key], al
	mov byte [key_update], 1

	cmp eax, 0x80
	jl keyboard_int_keydown

	jmp keyboard_int_keyup


keyboard_int_keydown:
	mov byte [last_state], 1 ; down
	mov byte [last_key_down], al

jmp keyboard_int_end


keyboard_int_keyup:
	mov byte [last_state], 2 ; up
	mov byte [last_key_up], al

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
