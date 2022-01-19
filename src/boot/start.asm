[bits 32]
[org 500h]

; get_cursor_pos use interrupts
; but interrupts now isn't working -> print isn't working, use print_at

jmp start

%include "src/include/string.asm"
%include "src/include/disk.asm"


start:
	push dword gpt
	push dword 1
	push dword 1
	call read_sector
	add esp, 4 * 3

	mov ecx, 0


	push dword 8
	push dword gpt
	push dword gpt_sign
	call arr_cmp
	add esp, 4 * 3

	cmp eax, 0
	je no_kernel


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


	push dword table
	push dword 1
	push dword 2
	call read_sector
	add esp, 4 * 3

	push ebx
	push ecx

	mov ebx, table
	mov ecx, [gpt + 0x50]

.loop1:
	push dword 16
	push dword my_guid_fs
	push dword ebx
	call arr_cmp
	add esp, 4 * 3

	cmp eax, 1
	je .loop1_end

	cmp ecx, 0
	je no_kernel

	dec ecx
	add ebx, 128
jmp .loop1


.loop1_end:
	pop ecx
	pop ebx




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

kernel_msg: db "Kernel found.", 0

gpt: times 512 db 0
gpt_sign: db "EFI PART", 0

table_lba: times 8 db 0
entries_count: times 4 db 0
entry_size: times 4 db 0

table: times 512 db 0

my_guid_fs: db 0x33, 0x74, 0x54, 0xE1, 0xAA, 0x9A, 0x79, 0x85, 0x51, 0x41, 0x2E, 0x78, 0xB2, 0xE6, 0x91, 0xEC