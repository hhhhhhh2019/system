[bits 32]

%define VIDEO_ADDERS 0xb8000
%define MAX_ROWS 25
%define MAX_COLS 80

; char ch, char attr, int col, int row
print_char_at:
	push ebp
	push ebx

	mov ebp, esp

	mov bl, [ebp + 12 + 0] ; ch
	mov bh, [ebp + 12 + 4] ; attr
	
	push dword [ebp + 12 + 12] ; row
	push dword [ebp + 12 + 8] ; col
	call get_offset
	add esp, 4 * 2

	mov ebp, VIDEO_ADDERS
	add ebp, eax

	mov [ebp], bx

	add eax, 2

	pop ebx
	pop ebp
ret


; char* str, char attr, int col, int row
print_at:
	push ebp
	push esi
	push ebx

	mov ebp, esp

	
	mov esi, [ebp + 4 * 4 + 4 * 0] ; str

	
	push dword [ebp + 4 * 4 + 4 * 3]
	push dword [ebp + 4 * 4 + 4 * 2]
	call get_offset
	add esp, 4 * 2

	mov ebx, eax ; save offset

print_at_loop:
	cmp byte [esi], 0
	je print_at_end

	push dword ebx
	call get_offset_row
	pop dword ebx
	push eax ; row

	push dword ebx
	call get_offset_col
	pop dword ebx
	push eax ; col
	
	push dword [ebp + 4 * 4 + 4 * 1] ; attr
	push dword [esi] ; ch
	call print_char_at
	add esp, 4 * 4

	inc esi
	inc ebx
jmp print_at_loop
	

print_at_end:
	pop ebx
	pop esi
	pop ebp
ret


; int col, int row

; eax = 2 * (row * MAX_COLS + col)

get_offset:
	push ebp
	push ebx

	mov ebp, esp

	mov eax, [ebp + 12 + 4] ; row
	mov ebx, MAX_COLS
	mul ebx ; eax = row * MAX_COLS

	mov ebp, [ebp + 12 + 0]
	add eax, ebp ; eax += col

	shl eax, 1 ; eax *= 2
	
	pop ebx
	pop ebp
ret


; int offset 

; eax = offset / (2 * MAX_COLS)

get_offset_row:
	push ebp

	mov ebp, esp

	mov eax, [ebp + 2 * 4 + 0] ; offset
	
	mov ebp, 2 * MAX_COLS
	div ebp ; eax /= 2 * MAX_COLS

	pop ebp
ret

; int offset 

; eax = (offset - (get_offset_row(offset) * 2 * MAX_COLS)) / 2

get_offset_col:
	push ebp

	mov ebp, esp

	push dword [ebp + 2 * 4 + 0]
	call get_offset_row ; eax = get_offset_row(offset)
	
	mov ebp, 2 * MAX_COLS
	mul ebp ; eax = get_offset_row(offset) * 2 * MAX_COLS
	
	pop ebp
	sub ebp, eax ; ebp = offset - eax

	mov eax, ebp ; eax = ebp

	shr eax, 1 ; eax /= 2

	pop ebp
ret