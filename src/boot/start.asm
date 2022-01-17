[bits 32]
[org 500h]

; get_cursor_pos use interrupts
; but interrupts now isn't working -> print isn't working, use print_at

jmp start

%include "src/include/screen.asm"
%include "src/include/disk.asm"

start:
	push dword gpt
	push dword 1
	push dword 1
	call read_sector
	add esp, 4 * 3

	mov ecx, 0

loop1:
	mov byte al, [gpt + ecx]
	mov byte ah, [gpt_sign + ecx]
	cmp al, ah
	jne no_gpt

	inc ecx

	cmp ecx, 8
	jl loop1


	mov dword eax, [gpt + 0x48] ; table lba
	mov dword [table_lba], eax
	mov dword eax, [gpt + 0x4b] ; table lba
	mov dword [table_lba + 4], eax

	mov dword eax, [gpt + 0x50] ; count
	mov dword [entries_count], eax

	mov dword eax, [gpt + 0x54] ; entry size
	mov dword [entry_size], eax

	cmp dword [entries_count], 0
	je no_sectons

	cmp dword [entries_count], 2
	jl no_kernel


jmp error

no_kernel:
	push dword 0
	push dword 0
	push dword 0x0f
	push no_kernel_msg
	call print_at
	add esp, 4 * 4

	jmp error

no_sectons:
	push dword 0
	push dword 0
	push dword 0x0f
	push no_sectons_msg
	call print_at
	add esp, 4 * 4

	jmp error

no_gpt:
	push dword 0
	push dword 0
	push dword 0x0f
	push no_gpt_msg
	call print_at
	add esp, 4 * 4

	jmp error

error:
	jmp $


no_gpt_msg: db "GPT not found!", 0
no_sectons_msg: db "No section found!", 0
no_kernel_msg: db "Kernel not found!", 0

gpt: times 512 db 0
gpt_sign: db "EFI PART", 0

table_lba: times 8 db 0
entries_count: times 4 db 0
entry_size: times 4 db 0