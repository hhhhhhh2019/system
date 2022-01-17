%ifndef DISK
%define DISK

%define ATA_BASE 0x1f0

%define SECTOR_SIZE   512
%define IDE_BSY       0x80
%define IDE_DRDY      0x40
%define IDE_DF        0x20
%define IDE_ERR       0x01

%define IDE_CMD_READ  0x20
%define IDE_CMD_WRITE 0x30
%define IDE_CMD_RDMUL 0xc4
%define IDE_CMD_WRMUL 0xc5


; addr, count, buffer
read_sector:
	push ebp
	push ecx

	mov ebp, esp

	push dword [ebp + 4 * 3 + 4 * 1]
	push dword ATA_BASE + 2 ; sector count
	call set_port_byte
	add esp, 4 * 2

	mov eax, [ebp + 4 * 3 + 4 * 0]
	inc eax
	and eax, 0xff
	push dword eax
	push dword ATA_BASE + 3 ; sector
	call set_port_byte
	add esp, 4 * 2

	mov eax, [ebp + 4 * 3 + 4 * 0]
	shr eax, 8
	and eax, 0xff
	push dword eax
	push dword ATA_BASE + 4 ; cylinder low
	call set_port_byte
	add esp, 4 * 2

	mov eax, [ebp + 4 * 3 + 4 * 0]
	shr eax, 16
	and eax, 0xff
	push dword eax
	push dword ATA_BASE + 5 ; cylinder high
	call set_port_byte
	add esp, 4 * 2

	mov eax, [ebp + 4 * 3 + 4 * 0]
	shr eax, 24
	and eax, 0xff
	or eax, 0xa0
	push dword eax
	push dword ATA_BASE + 6 ; head & drive
	call set_port_byte
	add esp, 4 * 2

	push dword 0x20
	push dword ATA_BASE + 7
	call set_port_byte
	add esp, 4 * 2


.loop:
	push dword ATA_BASE + 7
	call get_port_byte
	add esp, 4

	test eax, 8
	jz .loop
;jmp .loop

	mov eax, [ebp + 4 * 3 + 4 * 1]
	mov ecx, 256
	mul ecx
	mov ecx, eax

	mov ebp, [ebp + 4 * 3 + 4 * 2]

.loop2
	mov dx, ATA_BASE
	in ax, dx

	mov byte [ebp], al
	mov byte [ebp + 1], ah

	dec ecx
	add ebp, 2

	cmp ecx, 0
	jne .loop2


	pop ecx
	pop ebp
ret

%endif