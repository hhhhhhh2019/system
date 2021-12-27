; int from, int to, int count
memcpy:
	push ebp
	push ecx
	push esi
	push ebx

	mov ebp, esp

	mov esi, [ebp + 5 * 4 + 4 * 0] ; from
	push dword [ebp + 5 * 4 + 4 * 1] ; to
	mov ecx, 0 ; count

	pop ebp

memcpy_loop:
	cmp ecx, [ebp + 5 * 4 + 4 * 2]
	je memcpy_end

	mov ebx, [esi + ecx]

	mov [ebp + ecx], ebx

	inc ecx
jmp memcpy_loop

memcpy_end:
	pop ebx
	pop esi
	pop ecx
	pop ebp
ret
