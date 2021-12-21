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
	
	push dword [ebp + 12 + 8] ; col
	push dword [ebp + 12 + 12] ; row
	call get_offset
	pop dword [null]
	pop dword [null]

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

	mov esi, [ebp + 16 + 0] ; str

	push dword [ebp + 16 + 8] ; col
	push dword [ebp + 16 + 12] ; row
	call get_offset
	pop dword [null]
	pop dword [null]

	mov ebx, eax ; save offset

print_at_loop:
	cmp byte [esi], 0
	je print_at_end


	push ebx
	call get_offset_row
	pop ebx
	push eax ; row

	push ebx
	call get_offset_col
	pop ebx
	push eax ; col

	push dword [ebp + 16 + 4] ; attr
	push dword [esi] ; ch
	
	call print_char_at

	pop dword [null]
	pop dword [null]
	pop dword [null]
	pop dword [null]


	inc esi
	mov ebx, eax
jmp print_at_end

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

	mov eax, [ebp + 12 + 0] ; row
	mov ebx, MAX_COLS
	mul ebx ; eax = row * MAX_COLS

	mov ebp, [ebp + 12 + 4]
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

	mov eax, [ebp + 8 + 0]

	mov ebp, 2 * MAX_COLS
	div ebp

	pop ebp
ret

; int offset 

; eax = (offset - (get_offset_row(offset)*2*MAX_COLS))/2

get_offset_col:
	push ebp
	push ebx

	mov ebp, esp

	push dword [ebp + 12 + 0] ; offset
	call get_offset_row ; arg(offset) already in stack

	mov ebx, 2 * MAX_COLS
	mul ebx ; eax = get_offset_row(offset)*2*MAX_COLS

	push eax
	pop eax
	pop ebx

	sub eax, ebx ; eax = offset - eax

	mov ebx, 2
	div ebx

	push ebx
	pop ebp
ret