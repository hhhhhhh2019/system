%define REG_SCREEN_CTRL 0x3d4
%define REG_SCREEN_DATA 0x3d5

; int port
get_port_byte:
	push ebp
	push edx

	mov ebp, esp

	mov dx, [ebp + 3 * 4 + 0] ; port
	mov eax, 0

	in al, dx

	pop edx
	pop ebp
ret

; int port, int data
set_port_byte:
	push ebp
	push edx

	mov ebp, esp

	mov eax, 0

	mov dx, [ebp + 3 * 4 + 0 * 4] ; port
	mov al, [ebp + 3 * 4 + 1 * 4] ; port

	out dx, al

	pop edx
	pop ebp
ret


; int port
get_port_word:
	push ebp
	push edx

	mov ebp, esp

	mov dx, [ebp + 3 * 4 + 0] ; port
	mov eax, 0

	in ax, dx

	pop edx
	pop ebp
ret

; int port, int data
set_port_word:
	push ebp
	push edx

	mov ebp, esp

	mov eax, 0

	mov dx, [ebp + 3 * 4 + 0 * 4] ; port
	mov ax, [ebp + 3 * 4 + 1 * 4] ; data

	out dx, ax

	pop edx
	pop ebp
ret
