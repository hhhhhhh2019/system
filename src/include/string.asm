%ifndef STRING
%define STRING

%include "src/include/screen.asm"

;char* str
str_len:
	push ebp
	
	mov ebp, [esp + 4 * 2 + 0]

	mov eax, 0

.loop:
	cmp byte [ebp], 0
	je .end

	inc eax
	inc ebp
jmp .loop

.end
	pop ebp
ret


; char* str1, char* str2, int count
; 1 - ok, 0 - error
arr_cmp:
	push ebp
	push esi
	  push ebx

	mov ebp, [esp + 4 * 4 + 4 * 0]
	mov esi, [esp + 4 * 4 + 4 * 1]
	mov eax, [esp + 4 * 4 + 4 * 2]

.loop:
	cmp eax, 0
	je .ok

	mov byte bl, [ebp]
	mov byte bh, [esi]

	cmp bl, bh
	jne .error

	inc ebp
	inc esi
	dec eax
jmp .loop

.ok:
	mov eax, 1
	jmp .end

.error:
	mov eax, 0

.end:
	  pop ebx
	pop esi
	pop ebp
ret



%endif
