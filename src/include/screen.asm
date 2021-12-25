%define VIDEO_ADDERS 0xb8000
%define MAX_ROWS 25
%define MAX_COLS 80


; char ch, char attr, int col, int row
print_char_at:
	push ebp
	push ebx

	mov ebp, esp

	mov bl, [ebp + 3 * 4 + 0 * 4] ; ch
	mov bh, [ebp + 3 * 4 + 1 * 4] ; attr

	push dword [ebp + 3 * 4 + 3 * 4] ; row
	push dword [ebp + 3 * 4 + 2 * 4] ; col
	call get_offset
	add esp, 4 * 2
	; eax = offset

	cmp bl, 0x0a ; \n
	je print_char_at_1

	cmp bl, 0x0d ; \r
	je print_char_at_2

	jmp print_char_at_3

print_char_at_1:
	add eax, MAX_COLS * 2

	jmp print_char_at_end

print_char_at_2:
	push eax
	call get_offset_row
	add esp, 4
	; eax = get_offset_row(offset)

	push ebx
	mov ebx, MAX_COLS * 2
	mul ebx ; eax *= MAX_COLS * 2
	pop ebx

	jmp print_char_at_end

print_char_at_3:
	mov ebp, VIDEO_ADDERS
	add ebp, eax
	mov [ebp], bx

	add eax, 2

print_char_at_end:
	pop ebx
	pop ebp
ret


; char* str, char attr, int col, int row
print_at:
	push ebp
	push esi
	push ebx

	mov ebp, esp

	mov esi, [ebp + 4 * 4 + 0 * 4] ; *str

	push dword [ebp + 4 * 4 + 3 * 4] ; row
	push dword [ebp + 4 * 4 + 2 * 4] ; col
	call get_offset
	add esp, 4 * 2

	mov ebx, eax

print_at_loop:
	cmp byte [esi], 0
	je print_at_end

	push ebx
	call get_offset_row
	add esp, 4

	push eax

	push ebx
	call get_offset_col
	add esp, 4

	push eax

	push dword [ebp + 4 * 4 + 1 * 4] ; attr
	push dword [esi] ; ch
	call print_char_at
	add esp, 4 * 4

	mov ebx, eax
	inc esi

jmp print_at_loop

print_at_end:
	pop ebx
	pop esi
	pop ebp
ret


; int col, int row
; return (row * MAX_COLS + col) * 2
get_offset:
	push ebp
	push ebx

	mov ebp, esp

	mov eax, [ebp + 3 * 4 + 1 * 4] ; row
	mov ebx, [ebp + 3 * 4 + 0 * 4] ; col

	mov ebp, MAX_COLS
	mul ebp

	add eax, ebx

	shl eax, 1

	pop ebx
	pop ebp
ret


; int offset
; return offset / (MAX_COLS * 2)
get_offset_row:
	push ebp

	mov ebp, esp

	mov eax, [ebp + 2 * 4 + 0] ; offset

	mov ebp, MAX_COLS * 2

	div ebp ; eax /= MAX_COLS * 2

	mov eax, ebp

	pop ebp
ret

; int offset
; return (offset - get_offset_row(offset) * MAX_COLS * 2) / 2
get_offset_col:
	push ebp
	push ebx

	mov ebp, esp

	push dword [ebp + 3 * 4 + 0] ; offset
	call get_offset_row
	add esp, 4

	mov ebx, MAX_COLS * 2
	mul ebx

	mov ebx, [ebp + 3 * 4 + 0] ; offset
	sub ebx, eax ; offset - get_offset_row(offset) * MAX_COLS * 2

	shr ebx, 1 ; offset /= 2

	mov eax, ebx

	pop ebx
	pop ebp
ret
