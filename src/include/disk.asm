%ifndef DISK
%define DISK

%define ATA_BASE 0x1f0
%define ATA_CONTROL 0x3f4

%define IDE_BSY       0x80
%define IDE_DRDY      0x40
%define IDE_DF        0x20
%define IDE_ERR       0x01

%define IDE_CMD_READ  0x20
%define IDE_CMD_WRITE 0x30
%define IDE_CMD_RDMUL 0xc4
%define IDE_CMD_WRMUL 0xc5


;def add_lba(lba, num):
;     s = (lba & 0xff) + num
;     c = ((lba & 0xffff00) >> 8) + s // 64
;     s -= s // 64 * 64
;     h = ((lba & 0xff000000) >> 24) + c // 65536
;     c -= c // 65536 * 65536
;     return (s, c, h)

; lba, num
add_lba:
	push ebp
	push ebx
	push edx

	
	

	pop edx
	pop ebx
	pop ebp
ret

; addr, count, buffer
read_sector:
	push ebp
	push ecx

	push dword [esp + 4 * 3 + 4 * 1]
	push dword ATA_BASE + 2 ; sectors count
	call set_port_byte
	add esp, 4 * 2

	
	mov eax, [esp + 4 * 3 + 4 * 0] ; addr
	
	and eax, 0xff
	push dword eax
	push dword ATA_BASE + 3 ; lba
	call set_port_byte
	add esp, 4 * 2


	mov eax, [esp + 4 * 3 + 4 * 0] ; addr
	
	shr eax, 8
	and eax, 0xff
	push dword eax
	push dword ATA_BASE + 4 ; lba
	call set_port_byte
	add esp, 4 * 2


	mov eax, [esp + 4 * 3 + 4 * 0] ; addr
	
	shr eax, 16
	and eax, 0xff
	push dword eax
	push dword ATA_BASE + 5 ; lba
	call set_port_byte
	add esp, 4 * 2

	
	mov eax, [esp + 4 * 3 + 4 * 0] ; addr

	shr eax, 24
	and eax, 0x0f
	or eax, 0xe0
	push dword eax
	push dword ATA_BASE + 6
	call set_port_byte
	add esp, 4 * 2 ; head & drive


	push dword 0x20
	push dword ATA_BASE + 7
	call set_port_byte
	add esp, 4 * 2

	
.loop1:
	push dword ATA_BASE + 7
	call get_port_byte
	add esp, 4

	test al, 8
	jz .loop1
	

	mov ebp, [esp + 4 * 3 + 4 * 2]
	mov ecx, 256

	push edx

.read_loop:
	mov dx, ATA_BASE
	in ax, dx
	
	mov [ebp], al
	mov [ebp + 1], ah

	add ebp, 2

	dec ecx

	cmp ecx, 0
	jne .read_loop

	
	pop edx
	pop ecx
	pop ebp
ret

%endif
