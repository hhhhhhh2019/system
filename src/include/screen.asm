%define VIDEO_ADDERS 0xb8000
%define MAX_ROWS 25
%define MAX_COLS 80


; char ch, char attr, int col, int row
print_char_at:
	push ebp
	push ebx

	mov ebp, esp

	mov bh, [ebp + 3 * 4 + 1 * 4] ; attr
	mov bl, [ebp + 3 * 4 + 0 * 4] ; ch

	push dword [ebp + 3 * 4 + 3 * 4] ; row
	push dword [ebp + 3 * 4 + 2 * 4] ; col
	call get_offset
	add esp, 4 * 2
	; eax = offset


	mov ebp, VIDEO_ADDERS
	add ebp, eax
	mov [ebp], bx

	add eax, 2

	pop ebx
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
