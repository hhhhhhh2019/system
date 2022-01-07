%define ATA_BASE 0x1f0


; addr, count, buffer
read_sector:
	push ebp
	push ecx
	
	mov ebp, esp
	
	mov eax, [ebp + 4 * 3 + 4 * 1] ; count
	mov ebp, [ebp + 4 * 3 + 4 * 2] ; buffer
	
	mov ecx, 512
	mul ecx
	mov ecx, eax
	
	
	push dword 1
	push dword ATA_BASE + 2
	call set_port_byte
	add esp, 4 * 2
	
	
	push dword 0 ; sector
	push dword ATA_BASE + 3
	call set_port_byte
	add esp, 4 * 2
	
	
	push dword 0 ; cylinder_low
	push dword ATA_BASE + 4
	call set_port_byte
	add esp, 4 * 2
	
	
	push dword 0 ; cylinder_high
	push dword ATA_BASE + 5
	call set_port_byte
	add esp, 4 * 2
	
	push dword 10100000b ; head
	push dword ATA_BASE + 6
	call set_port_byte
	add esp, 4 * 2
	
	
	push dword 0x20
	push dword ATA_BASE + 7
	call set_port_byte
	add esp, 4 * 2
	
	
	;push dword ATA_BASE + 7
	;call get_port_byte
	;add esp, 4
	
	mov dx, ATA_BASE + 7
	
read_sector_loop:
	;and eax, 0x88
	in al, dx
	test al, 8
	jz read_sector_loop_end
	
	;push dword ATA_BASE + 7
	;call get_port_byte
	;add esp, 4
jmp read_sector_loop
read_sector_loop_end:
	
	
read_sector_loop2:
	cmp ecx, 0
	je read_sector_loop2_end
	
	push dword ATA_BASE
	call get_port_byte
	add esp, 4
	
;	dec al
	
	mov byte [ebp], 'A';al
	
	dec ecx
	inc ebp

jmp read_sector_loop2
read_sector_loop2_end:
	
	pop ecx
	pop ebp
ret
