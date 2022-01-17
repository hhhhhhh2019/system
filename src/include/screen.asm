%ifndef SCREEN
%define SCREEN

%include "src/include/port.asm"
%include "src/include/util.asm"

%define VIDEO_ADDRESS 0xb8000
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
	call get_offset ; eax = offset
	add esp, 4 * 2

	cmp bl, 0x0a ; \n
	je print_char_at_1

	cmp bl, 0x0d ; \r
	je print_char_at_2

	jmp print_char_at_3 ; EOL

print_char_at_1:
	add eax, MAX_COLS * 2

	jmp print_char_at_end

print_char_at_2:
	mov eax, [ebp + 3 * 4 + 3 * 4] ; row

	mov ebx, MAX_COLS * 2
	mul ebx

	jmp print_char_at_end

print_char_at_3:
	mov ebp, VIDEO_ADDRESS
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


; char* str, char attr
print:
	push ebp
	push esi
	push ebx

	mov ebp, esp

	mov esi, [ebp + 4 * 4 + 0 * 4] ; *str

	call get_cursor_pos
	mov ebx, eax

print_loop:
	cmp byte [esi], 0
	je print_end

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

jmp print_loop

print_end:
	pop ebx
	pop esi
	pop ebp
ret


scroll_screen:
	push ecx
	push eax

	mov ecx, 1

scroll_screen_loop:
	cmp ecx, MAX_ROWS - 1
	je scroll_screen_end
	; memcpy(VIDEO_ADDRESS + ecx * MAX_COLS * 2, VIDEO_ADDRESS + (ecx - 1) * MAX_COLS * 2, MAX_COLS * 2)

	push dword MAX_COLS * 2 ; count

	; VIDEO_ADDRESS + (ecx - 1) * MAX_COLS * 2
	mov eax, MAX_ROWS * 2
	push ecx
	dec ecx
	mul ecx
	pop ecx
	add eax, VIDEO_ADDRESS
	push dword eax ; to

	; VIDEO_ADDRESS + ecx * MAX_COLS * 2
	mov eax, MAX_COLS * 2
	mul ecx
	add eax, VIDEO_ADDRESS
	push dword eax; from

	call memcpy
	add esp, 4 * 3

	inc ecx
jmp scroll_screen_loop

scroll_screen_end:
	pop eax
	pop ecx
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

; int offset
set_cursor_pos:
	push ebp
	push ebx

	mov ebp, esp

	mov ebx, [ebp + 4 * 3 + 0] ; offset

	shr ebx, 1 ; effset /= 2

	push ebx

	and ebx, 0xff

	push dword 15
	push dword REG_SCREEN_CTRL
	call set_port_byte
	add esp, 8

	push dword ebx
	push dword REG_SCREEN_DATA
	call set_port_byte
	add esp, 8

	pop ebx

	and ebx, 0xff00

	shr ebx, 8

	push dword 14
	push dword REG_SCREEN_CTRL
	call set_port_byte
	add esp, 8

	push dword ebx
	push dword REG_SCREEN_DATA
	call set_port_byte
	add esp, 8

	pop ebx
	pop ebp
ret


get_cursor_pos:
	push ebx

	mov ebx, 0


	push dword 15
	push dword REG_SCREEN_CTRL
	call set_port_byte
	add esp, 8

	push dword REG_SCREEN_DATA
	call get_port_byte
	add esp, 4

	mov ebx, eax


	push dword 14
	push dword REG_SCREEN_CTRL
	call set_port_byte
	add esp, 8

	push dword REG_SCREEN_DATA
	call get_port_byte
	add esp, 4

	shl eax, 8
	add ebx, eax

	mov eax, ebx

	shl eax, 1


	pop ebx
ret

%endif
