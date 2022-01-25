[org 0x1100]
[bits 32]


jmp start

;%include "src/include/string.asm"
%include "src/kernel/isr.asm"
;%include "src/include/keyboard.asm"
;%include "src/include/disk.asm"

start:
	call init_idt
	;sti
jmp $
