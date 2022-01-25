%ifndef ISR
%define ISR

%define PIC1 0x20
%define PIC2 0xA0

%define ICW1 0x11
%define ICW4 0x01

%include "src/include/port.asm"
%include "src/kernel/int.asm"

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

	mov word [idt + ecx + 2], 0xb1000

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


init_pics:
	;port_byte_out(0x20, 0x11);
	;port_byte_out(0xA0, 0x11);
	;port_byte_out(0x21, 0x20);
	;port_byte_out(0xA1, 0x28);
	;port_byte_out(0x21, 0x04);
	;port_byte_out(0xA1, 0x02);
	;port_byte_out(0x21, 0x01);
	;port_byte_out(0xA1, 0x01);
	;port_byte_out(0x21, 0x0);
	;port_byte_out(0xA1, 0x0);

	push dword 0x11
	push dword PIC1
	call set_port_byte
	add esp, 4 * 2

	push dword 0x11
	push dword PIC2
	call set_port_byte
	add esp, 4 * 2


	push dword 0x20
	push dword PIC1 + 1
	call set_port_byte
	add esp, 4 * 2

	push dword 0x28
	push dword PIC2 + 1
	call set_port_byte
	add esp, 4 * 2


	push dword 0x04
	push dword PIC1 + 1
	call set_port_byte
	add esp, 4 * 2

	push dword 0x02
	push dword PIC2 + 1
	call set_port_byte
	add esp, 4 * 2


	push dword 0x01
	push dword PIC1 + 1
	call set_port_byte
	add esp, 4 * 2

	push dword 0x01
	push dword PIC2 + 1
	call set_port_byte
	add esp, 4 * 2


	push dword 0xff
	push dword PIC1 + 1
	call set_port_byte
	add esp, 4 * 2

	push dword 0xff
	push dword PIC2 + 1
	call set_port_byte
	add esp, 4 * 2
ret


init_idt:
	push dword int0
	push dword 0
	call set_idt_gate
	add esp, 4 * 2

	push dword int1
	push dword 1
	call set_idt_gate
	add esp, 4 * 2

	push dword int2
	push dword 2
	call set_idt_gate
	add esp, 4 * 2

	push dword int3
	push dword 3
	call set_idt_gate
	add esp, 4 * 2

	push dword int4
	push dword 4
	call set_idt_gate
	add esp, 4 * 2

	push dword int5
	push dword 5
	call set_idt_gate
	add esp, 4 * 2

	push dword int6
	push dword 6
	call set_idt_gate
	add esp, 4 * 2

	push dword int7
	push dword 7
	call set_idt_gate
	add esp, 4 * 2

	push dword int8
	push dword 8
	call set_idt_gate
	add esp, 4 * 2

	push dword int9
	push dword 9
	call set_idt_gate
	add esp, 4 * 2

	push dword int10
	push dword 10
	call set_idt_gate
	add esp, 4 * 2

	push dword int11
	push dword 11
	call set_idt_gate
	add esp, 4 * 2

	push dword int12
	push dword 12
	call set_idt_gate
	add esp, 4 * 2

	push dword int13
	push dword 13
	call set_idt_gate
	add esp, 4 * 2

	push dword int14
	push dword 14
	call set_idt_gate
	add esp, 4 * 2

	push dword int15
	push dword 15
	call set_idt_gate
	add esp, 4 * 2

	push dword int16
	push dword 16
	call set_idt_gate
	add esp, 4 * 2

	push dword int17
	push dword 17
	call set_idt_gate
	add esp, 4 * 2

	push dword int18
	push dword 18
	call set_idt_gate
	add esp, 4 * 2

	push dword int19
	push dword 19
	call set_idt_gate
	add esp, 4 * 2

	push dword int20
	push dword 20
	call set_idt_gate
	add esp, 4 * 2

	push dword int21
	push dword 21
	call set_idt_gate
	add esp, 4 * 2

	push dword int22
	push dword 22
	call set_idt_gate
	add esp, 4 * 2

	push dword int23
	push dword 23
	call set_idt_gate
	add esp, 4 * 2

	push dword int24
	push dword 24
	call set_idt_gate
	add esp, 4 * 2

	push dword int25
	push dword 25
	call set_idt_gate
	add esp, 4 * 2

	push dword int26
	push dword 26
	call set_idt_gate
	add esp, 4 * 2

	push dword int27
	push dword 27
	call set_idt_gate
	add esp, 4 * 2

	push dword int28
	push dword 28
	call set_idt_gate
	add esp, 4 * 2

	push dword int29
	push dword 29
	call set_idt_gate
	add esp, 4 * 2

	push dword int30
	push dword 30
	call set_idt_gate
	add esp, 4 * 2

	push dword int31
	push dword 31
	call set_idt_gate
	add esp, 4 * 2


	call init_pics


	push dword irq0
	push dword 32
	call set_idt_gate
	add esp, 4 * 2

	push dword irq1
	push dword 33
	call set_idt_gate
	add esp, 4 * 2

	push dword irq2
	push dword 34
	call set_idt_gate
	add esp, 4 * 2

	push dword irq3
	push dword 35
	call set_idt_gate
	add esp, 4 * 2

	push dword irq4
	push dword 36
	call set_idt_gate
	add esp, 4 * 2

	push dword irq5
	push dword 37
	call set_idt_gate
	add esp, 4 * 2

	push dword irq6
	push dword 38
	call set_idt_gate
	add esp, 4 * 2

	push dword irq7
	push dword 39
	call set_idt_gate
	add esp, 4 * 2

	push dword irq8
	push dword 40
	call set_idt_gate
	add esp, 4 * 2

	push dword irq9
	push dword 41
	call set_idt_gate
	add esp, 4 * 2

	push dword irq10
	push dword 42
	call set_idt_gate
	add esp, 4 * 2

	push dword irq11
	push dword 43
	call set_idt_gate
	add esp, 4 * 2

	push dword irq12
	push dword 44
	call set_idt_gate
	add esp, 4 * 2

	push dword irq13
	push dword 45
	call set_idt_gate
	add esp, 4 * 2

	push dword irq14
	push dword 46
	call set_idt_gate
	add esp, 4 * 2

	push dword irq15
	push dword 47
	call set_idt_gate
	add esp, 4 * 2

	call set_idt
ret


%endif
