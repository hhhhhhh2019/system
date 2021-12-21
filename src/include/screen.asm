%define VIDEO_ADDERS 0xb8000
%define MAX_ROWS 25
%define MAX_COLS 80

; char str, int col, int row, char attr
print_at:
	push ebp
	push ebx
	push esi

	mov ebp, esp
	mov esi, [ebp + 16 + 0] ; str
	mov bh, [ebp + 16 + 4] ; attr
	
	push dword [ebp + 16 + 8] ; col
	push dword [ebp + 16 + 12] ; row
	call get_offset
	pop dword [null]
	pop dword [null]

	mov ebp, VIDEO_ADDERS
	add ebp, eax

print_char_loop:
	mov bl, [esi]

	cmp bl, 0
	je print_char_end

	mov [ebp], bx

	inc esi
	add ebp, 2
jmp print_char_loop

print_char_end:
	pop esi
	pop ebx
	pop ebp
ret


; int col, int row

; eax = 2 * (row * MAX_COLS + col)

get_offset:
	push ebp
	push ebx

	mov ebp, esp

	mov eax, [ebp + 12 + 0] ; row
	mov ebx, MAX_COLS
	mul ebx ; eax = row * MAX_COLS

	mov ebp, [ebp + 12 + 4]
	add eax, ebp ; eax += col

	shl eax, 1 ; eax *= 2
	
	pop ebx
	pop ebp
ret