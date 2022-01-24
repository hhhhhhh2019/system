[org 7c00h]
[bits 16]


jmp start

boot_disk: dw 0


gdt_start:
	dd 0x0 ; 4 byte
	dd 0x0 ; 4 byte

gdt_code:
	dw 0xffff    ; segment length, bits 0-15
    dw 0x0       ; segment base, bits 0-15
    db 0x0       ; segment base, bits 16-23
    db 10011010b ; flags (8 bits)
    db 11001111b ; flags (4 bits) + segment length, bits 16-19
    db 0x0       ; segment base, bits 24-31

gdt_data:
	dw 0xffff
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0

gdt_end:

gdt_descriptor:
	dw gdt_end - gdt_start - 1 ; size
	dd gdt_start ; address

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start



start:
	mov byte [boot_disk], dl

	mov bp, 0x9000
	mov sp, bp

	mov ah, 0
	mov al, 3
	int 10h

	mov ax, 0
	mov es, ax
	mov bx, 500h
	mov ah, 02h ; read sector
	mov dl, 80h
	mov dh, 0
	mov ch, 0
	mov cl, 35 ; sector + 1
	mov al, 20 ; sectors count
	int 13h

	; enter to 32 bit mode
	cli
	lgdt [gdt_descriptor]
	mov eax, cr0
	or eax, 1
	mov cr0, eax
	jmp CODE_SEG:init_pm

[bits 32]
init_pm:
	mov ax, DATA_SEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov ebp, 0x90000
	mov esp, ebp

	push dword [boot_disk]
	jmp 0x500

times 512-($-$$)-2 db 0

dw 0xaa55
