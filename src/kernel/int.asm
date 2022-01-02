%ifndef INT
%define INT

%include "src/include/screen.asm"


timer: dw 0


isr_handler:

ret

irq_handler:

ret


isr_common_stub:
	call get_cursor_pos

	push ebp
	mov ebp, VIDEO_ADDRESS
	mov byte [ebp + eax], 'I'
	mov byte [ebp + eax + 1], 0x0f
	pop ebp

	add eax, 2

	push eax
	call set_cursor_pos
	add esp, 4
	sti
ret

irq_common_stub:
	push dword 0xA0
	push dword 0x20
	call set_port_byte
	add esp, 4 * 2

	push dword 0x20
	push dword 0x20
	call set_port_byte
	add esp, 4 * 2


	call get_cursor_pos

	push ebp
	mov ebp, VIDEO_ADDRESS
	mov byte [ebp + eax], 'Q'
	mov byte [ebp + eax + 1], 0x0f
	pop ebp

	add eax, 2

	push eax
	call set_cursor_pos
	add esp, 4

	sti
ret


; Division By Zero
int0:
	cli
	push dword 0
	call isr_common_stub
	add esp, 4
iret

; Debug
int1:
	cli
	push dword 1
	call isr_common_stub
	add esp, 4
iret

; Non Maskable Interrupt
int2:
	cli
	push dword 2
	call isr_common_stub
	add esp, 4
iret

; Breakpoint
int3:
	cli
	push dword 3
	call isr_common_stub
	add esp, 4
iret

; Into Detected Overflow
int4:
	cli
	push dword 4
	call isr_common_stub
	add esp, 4
iret

; Out of Bounds
int5:
	cli
	push dword 5
	call isr_common_stub
	add esp, 4
iret

; Invalid Opcode
int6:
	cli
	push dword 6
	call isr_common_stub
	add esp, 4
iret

; No Coprocessor
int7:
	cli
	push dword 7
	call isr_common_stub
	add esp, 4
iret

; Double Fault
int8:
	cli
	push dword 8
	call isr_common_stub
	add esp, 4
iret

; Coprocessor Segment Overrun
int9:
	cli
	push dword 9
	call isr_common_stub
	add esp, 4
iret

; Bad TSS
int10:
	cli
	push dword 10
	call isr_common_stub
	add esp, 4
iret

; Segment Not Present
int11:
	cli
	push dword 11
	call isr_common_stub
	add esp, 4
iret

; Stack Fault
int12:
	cli
	push dword 12
	call isr_common_stub
	add esp, 4
iret

; General Protection Fault
int13:
	cli
	push dword 13
	call isr_common_stub
	add esp, 4
iret

; Page Fault
int14:
	cli
	push dword 14
	call isr_common_stub
	add esp, 4
iret

; Unknown Interrupt
int15:
	cli
	push dword 15
	call isr_common_stub
	add esp, 4
iret

; Coprocessor Fault
int16:
	cli
	push dword 16
	call isr_common_stub
	add esp, 4
iret

; Alignment Check
int17:
	cli
	push dword 17
	call isr_common_stub
	add esp, 4
iret

; Machine Check
int18:
	cli
	push dword 18
	call isr_common_stub
	add esp, 4
iret

; Reserved
int19:
	cli
	push dword 19
	call isr_common_stub
	add esp, 4
iret

; Reserved
int20:
	cli
	push dword 20
	call isr_common_stub
	add esp, 4
iret

; Reserved
int21:
	cli
	push dword 21
	call isr_common_stub
	add esp, 4
iret

; Reserved
int22:
	cli
	push dword 22
	call isr_common_stub
	add esp, 4
iret

; Reserved
int23:
	cli
	push dword 23
	call isr_common_stub
	add esp, 4
iret

; Reserved
int24:
	cli
	push dword 24
	call isr_common_stub
	add esp, 4
iret

; Reserved
int25:
	cli
	push dword 25
	call isr_common_stub
	add esp, 4
iret

; Reserved
int26:
	cli
	push dword 26
	call isr_common_stub
	add esp, 4
iret

; Reserved
int27:
	cli
	push dword 27
	call isr_common_stub
	add esp, 4
iret

; Reserved
int28:
	cli
	push dword 28
	call isr_common_stub
	add esp, 4
iret

; Reserved
int29:
	cli
	push dword 29
	call isr_common_stub
	add esp, 4
iret

; Reserved
int30:
	cli
	push dword 30
	call isr_common_stub
	add esp, 4
iret

; Reserved
int31:
	cli
	push dword 31
	call isr_common_stub
	add esp, 4
iret


; timer
irq0:
	cli

	inc dword [timer]
	mov byte [key_update], 0

	sti
iret

; keyboard
irq1:
	cli
	push dword 1
	call irq_common_stub
	add esp, 4
iret

irq2:
	cli
	push dword 2
	call irq_common_stub
	add esp, 4
iret

irq3:
	cli
	push dword 3
	call irq_common_stub
	add esp, 4
iret

irq4:
	cli
	push dword 4
	call irq_common_stub
	add esp, 4
iret

irq5:
	cli
	push dword 5
	call irq_common_stub
	add esp, 4
iret

irq6:
	cli
	push dword 6
	call irq_common_stub
	add esp, 4
iret

irq7:
	cli
	push dword 7
	call irq_common_stub
	add esp, 4
iret

irq8:
	cli
	push dword 8
	call irq_common_stub
	add esp, 4
iret

irq9:
	cli
	push dword 9
	call irq_common_stub
	add esp, 4
iret

irq10:
	cli
	push dword 10
	call irq_common_stub
	add esp, 4
iret

irq11:
	cli
	push dword 11
	call irq_common_stub
	add esp, 4
iret

irq12:
	cli
	push dword 12
	call irq_common_stub
	add esp, 4
iret

irq13:
	cli
	push dword 13
	call irq_common_stub
	add esp, 4
iret

irq14:
	cli
	push dword 14
	call irq_common_stub
	add esp, 4
iret

irq15:
	cli
	push dword 15
	call irq_common_stub
	add esp, 4
iret



%endif
