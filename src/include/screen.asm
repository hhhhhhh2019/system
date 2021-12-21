%define VIDEO_ADDERS 0xb8000

; char ch, char col, char row, char attr
print_char:
	push ebp
	push eax
	push esi

	mov ebp, esp
	mov esi, [ebp + 16 + 0]
	mov ah, [ebp + 16 + 4]

	mov ebp, VIDEO_ADDERS

print_char_loop:
	mov al, [esi]

	cmp al, 0
	je print_char_end

	mov [ebp], ax

	inc esi
	add ebp, 2
jmp print_char_loop

print_char_end:
	pop esi
	pop eax
	pop ebp
ret