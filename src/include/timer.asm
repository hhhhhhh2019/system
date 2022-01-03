; int freq
init_timer:
	push ebp
	
	mov ebp, esp
	
	mov ebp, [ebp + 4 * 2 + 0]
	
	mov eax, 1193180
	
	div ebp
	
	mov ebp, eax
	
	push dword 0x36
	push dword 0x43
	call set_port_byte
	add esp, 4 * 2
	
	and eax, 0xff
	
	push dword eax
	push dword 0x40
	call set_port_byte
	add esp, 4 * 2
	
	mov eax, ebp
	
	shr eax, 8
	
	and eax, 0xff
	
	push dword eax
	push dword 0x40
	call set_port_byte
	add esp, 4 * 2
	
	pop ebp
ret