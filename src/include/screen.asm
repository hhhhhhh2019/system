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
	add esp, 4 * 2 ; restore stack

	cmp bl, 0x0a
	je print_char_at_1
	cmp bl, 0x0d
	je print_char_at_2

	jmp print_char_at_3

print_char_at_1:
	add eax, MAX_COLS * 2 ; offset += MAX_COLS * 2

	jmp print_char_at_end

print_char_at_2:
	push eax
	call get_offset_row
	add esp, 4

	mov ebp, MAX_COLS * 2
	mul ebp ; offset = get_offset_row(offset) * MAX_COLS * 2

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
;
; int offset = get_offset(col, row);
; while (*str) {
; 	offset = print_char_at(*str, attr, get_offset_col(offset), get_offset_row(offset));
; 	str++;
; }
;
print_at:
	push ebp
	push esi
	push ebx

	mov ebp, esp

	
	mov esi, [ebp + 4 * 4 + 4 * 0] ; str

	; offset(ebx) = get_offset(col, row)
	push dword [ebp + 4 * 4 + 4 * 3] ; row
	push dword [ebp + 4 * 4 + 4 * 2] ; col
	call get_offset
	add esp, 4 * 2 ; restore stack

	mov ebx, eax ; save offset

; while
print_at_loop:
	; (*str(esi)) {
	cmp byte [esi], 0
	je print_at_end

	; offset(ebx) = print_char_at(*str(esi), attr, get_offset_col(offset(ebx)), get_offset_row(offset(ebx)));
	; get_offset_row(offset(ebx))
	push dword ebx
	call get_offset_row
	pop dword ebx

	push eax ; row

	; get_offset_col(offset(ebx))
	push dword ebx
	call get_offset_col
	pop dword ebx

	push eax ; col
	
	push dword [ebp + 4 * 4 + 4 * 1] ; attr
	push dword [esi] ; *str(esi)
	call print_char_at
	add esp, 4 * 4

	inc esi
	mov ebx, eax
jmp print_at_loop
; }
	

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

	mov ebp, [ebp + 12 + 0] ; col
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

	push dword [ebp + 2 * 4 + 0] ; offset
	call get_offset_row ; eax = get_offset_row(offset)
	
	mov ebp, 2 * MAX_COLS
	mul ebp ; eax *= 2 * MAX_COLS
	
	pop dword ebp ; offset
	sub ebp, eax ; ebp = offset - eax

	mov eax, ebp ; eax = ebp

	shr eax, 1

	pop ebp
ret