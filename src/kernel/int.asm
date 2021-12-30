%ifndef INT
%define INT

%include "src/include/screen.asm"

; desctiptor
; 	uint16 offset_low;
; 	uint16 selector;
; 	uint8 zero; always 0
; 	uint8 flags;
; 	uint16 offset_high;

idt: times 256 db 0,0,  0,0,  0,  0,  0,0

idt_pointer: dw 0, 0,0

; int n, *handler
set_idt_gate:
	push ebp
	push ecx
	push ebx

	mov ebp, esp

	mov eax, [ebp + 4 * 4 + 4 * 0] ; n
	mov ecx, 8
	mul ecx
	mov ecx, eax

	mov ebx, [ebp + 4 * 4 + 4 * 1] ; handler
	and ebx, 0x0000ffff
	mov [idt + ecx + 0], bx ; offset_low

	mov ebx, [ebp + 4 * 4 + 4 * 1] ; handler
	shr ebx, 16
	and ebx, 0x0000ffff
	mov [idt + ecx + 6], bx ; offset_high

	mov word [idt + ecx + 2], 0b1000

	mov byte [idt + ecx + 5], 0x8E ; flags

	pop ebx
	pop ecx
	pop ebp
ret

set_idt:
	mov word [idt_pointer + 0], idt_pointer - 1 ; limit
	mov dword [idt_pointer + 2], idt ; base
	mov eax, idt_pointer
	lidt [eax]
ret


%endif
