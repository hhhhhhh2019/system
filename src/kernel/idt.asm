%ifndef IDT
%define IDT

%define KERNEL_CS 0x08

idt_reg_limit: dd 0
idt_reg_base: dd 0, 0

idt: times 256 db 0, 0,  0, 0,  0,  0,  0, 0


;void set_idt_gate(int n, u32 handler) {
;	idt[n].low_offset = low_16(handler);
;	idt[n].sel = KERNEL_CS;
;	idt[n].always0 = 0;
;	idt[n].flags = 0x8E; 
;	idt[n].high_offset = high_16(handler);
;}
;
;void set_idt() {
;	idt_reg.base = (u32) &idt;
;	idt_reg.limit = IDT_ENTRIES * sizeof(idt_gate_t) - 1;
;	/* Don't make the mistake of loading &idt -- always load &idt_reg */
;	__asm__ __volatile__("lidtl (%0)" : : "r" (&idt_reg));
;}

set_idt_gate:

ret

set_idt:

ret

set_idt:
	mov dword [idt_reg_base], idt
	mov word [idt_reg_limit], 256 * 8 - 1
ret

%endif