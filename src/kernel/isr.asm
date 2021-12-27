%ifndef IRS
%define IRS


%include "src/include/screen.asm"
%include "src/kernel/idt.asm"


;void isr_install() {
;	set_idt_gate(0, (u32)isr0);
;	set_idt_gate(1, (u32)isr1);
;	set_idt_gate(2, (u32)isr2);
;	set_idt_gate(3, (u32)isr3);
;	set_idt_gate(4, (u32)isr4);
;	set_idt_gate(5, (u32)isr5);
;	set_idt_gate(6, (u32)isr6);
;	set_idt_gate(7, (u32)isr7);
;	set_idt_gate(8, (u32)isr8);
;	set_idt_gate(9, (u32)isr9);
;	set_idt_gate(10, (u32)isr10);
;	set_idt_gate(11, (u32)isr11);
;	set_idt_gate(12, (u32)isr12);
;	set_idt_gate(13, (u32)isr13);
;	set_idt_gate(14, (u32)isr14);
;	set_idt_gate(15, (u32)isr15);
;	set_idt_gate(16, (u32)isr16);
;	set_idt_gate(17, (u32)isr17);
;	set_idt_gate(18, (u32)isr18);
;	set_idt_gate(19, (u32)isr19);
;	set_idt_gate(20, (u32)isr20);
;	set_idt_gate(21, (u32)isr21);
;	set_idt_gate(22, (u32)isr22);
;	set_idt_gate(23, (u32)isr23);
;	set_idt_gate(24, (u32)isr24);
;	set_idt_gate(25, (u32)isr25);
;	set_idt_gate(26, (u32)isr26);
;	set_idt_gate(27, (u32)isr27);
;	set_idt_gate(28, (u32)isr28);
;	set_idt_gate(29, (u32)isr29);
;	set_idt_gate(30, (u32)isr30);
;	set_idt_gate(31, (u32)isr31);
;
;	set_idt(); // Load with ASM
;}

isr_install:
	push dword isr0
	push dword 0
	call set_idt_gate
	add esp, 4 * 2

	push dword isr1
	push dword 1
	call set_idt_gate
	add esp, 4 * 2

	push dword isr2
	push dword 2
	call set_idt_gate
	add esp, 4 * 2

	push dword isr3
	push dword 3
	call set_idt_gate
	add esp, 4 * 2

	push dword isr4
	push dword 4
	call set_idt_gate
	add esp, 4 * 2

	push dword isr5
	push dword 5
	call set_idt_gate
	add esp, 4 * 2

	push dword isr6
	push dword 6
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr7
	push dword 7
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr8
	push dword 8
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr8
	push dword 8
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr9
	push dword 9
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr10
	push dword 10
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr11
	push dword 11
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr12
	push dword 12
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr13
	push dword 13
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr14
	push dword 14
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr15
	push dword 15
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr16
	push dword 16
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr17
	push dword 17
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr18
	push dword 18
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr19
	push dword 19
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr20
	push dword 20
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr21
	push dword 21
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr22
	push dword 22
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr23
	push dword 23
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr24
	push dword 24
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr25
	push dword 25
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr26
	push dword 26
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr27
	push dword 27
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr28
	push dword 28
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr29
	push dword 29
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr30
	push dword 30
	call set_idt_gate
	add esp, 4 * 2
	
	push dword isr31
	push dword 31
	call set_idt_gate
	add esp, 4 * 2

	call set_idt
ret


isr_handler:
	push dword MAX_ROWS - 1
	push dword MAX_COLS - 1
	push dword 0x4a
	push dword 'X'
	call print_char_at
	add esp, 4 * 4
ret

%endif