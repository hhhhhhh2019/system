[org 500h]
[bits 32]

jmp start

%include "src/include/screen.asm"
%include "src/kernel/isr.asm"
%include "src/include/keyboard.asm"
%include "src/include/timer.asm"

keymap:
db 0,0,'1234567890-=',0,0,'qwertyuiop[]',0,0,'asdfghjkl;',"'",'``',0,'\zxcvbnm,./',0,0,0,' ',0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,

str: db 0,0

; int key
key_handler:
	mov eax, [esp + 4]
	
	
	; вам нравятся костыли?
	cmp eax, 0x80
	jl key_handler_continue
	
	jmp key_handler_end 
	

key_handler_continue:
	add eax, keymap
	mov ebp, eax
	mov eax, [ebp]

	mov byte [str], al

	push dword 0x0f
	push dword str
	call print
	add esp, 4 * 2

key_handler_end:
ret

start:
	call init_idt
	call keyboard_init
	push dword 100
	call init_timer
	add esp, 4
	
	push dword key_handler
	call add_key_handler
	add esp, 4
	
	sti
jmp $
