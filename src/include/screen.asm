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
	pop dword [0x505]
	pop dword [0x505]

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
	pop dword [0x505]
	pop dword [0x505]

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
	pop dword [0x505]
	pop dword [0x505]
	pop dword [0x505]
	pop dword [0x505]

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
	call get_offset_row
	pop dword [0x505]

	mov ebx, 2 * MAX_COLS
	mul ebx ; eax = get_offset_row(offset)*2*MAX_COLS

	mov ebx, [ebp + 12 + 0]

	sub ebx, eax ; ebx = offset - eax

	shr ebx, 1 ; ebx /= 2

	mov eax, ebx

	push ebx
	pop ebp
ret