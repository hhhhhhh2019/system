%define VIDEO_ADDERS 0xb8000

; char ch, char col, char row, char attr
print_char:
	push eax
	push ebp
	push dword si
	push ebx

	mov ebp, esp
	mov si, [ebp + 20 + 0]
	mov ah, [ebp + 20 + 4]

	mov ebp, VIDEO_ADDERS

print_char_loop:
	mov al, [si]

	cmp al, 0
	jz print_char_end

	mov al, 'X'
	mov ah, 0x0f
	
	mov [ebp], ax

	inc si
	add ebp, 2

	jmp print_char_loop

print_char_end:
	pop ebx
	pop dword si
	pop ebp
	pop eax
ret