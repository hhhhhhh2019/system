[bits 32]
[org 500h]

; get_cursor_pos use interrupts
; but interrupts now isn't working -> print isn't working, use print_at

jmp start

%include "src/include/string.asm"
%include "src/include/disk.asm"


;int* entry
check_kernel:
	push ebp
	push ecx
	push ebx

	mov dword ebp, [esp + 4 * 4 + 0]

	
	push dword 16
	push dword my_guid_fs_entry
	push dword ebp
	call arr_cmp
	add esp, 4 * 3

	cmp eax, 0
	je .error


	add ebp, 0x20
	mov dword ebp, [ebp]
	
	push dword mem
	push dword 1
	push dword ebp
	call read_sector ; read fs head
	add esp, 4 * 3


	push dword 8
	push dword my_guid_fs
	push dword mem
	call arr_cmp
	add esp, 4 * 3

	cmp eax, 0
	je .error
	
	cmp byte [mem + 24], 0
	jz .error ; if folders count == 0 -> error
	
	inc ebp
	
	push dword mem
	push dword 1
	push dword ebp
	call read_sector ; folders links
	add esp, 4 * 3

	mov dword ebp, [mem]

	
	push dword mem
	push dword 1
	push dword ebp
	call read_sector ; "sys" folder header
	add esp, 4 * 3


	push dword 3
	push dword mem + 10
	push dword sys
	call arr_cmp
	add esp, 4 * 3

	cmp eax, 0
	je .error


	push dword 1
	push dword 0
	push dword 0x0f
	push dword mem
	call print_at
	add esp, 4 * 4


	jmp .ok


.error:
	mov eax, 0
	jmp .end

.ok:
	mov eax, 1

.end:
	pop ebx
	pop ecx
	pop ebp
ret


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
	je no_gpt


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
	mov ecx, 0;[gpt + 0x50]

.loop1:
	push dword ebx
	call check_kernel
	add esp, 4

	cmp eax, 1
	je .loop1_end

	cmp dword ecx, [gpt + 0x50]
	je no_kernel

	add ebx, 128
	inc ecx
jmp .loop1

.loop1_end:
	mov eax, ebx
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

mem: times 512 db 0

my_guid_fs_entry: db 0x33, 0x74, 0x54, 0xE1, 0xAA, 0x9A, 0x79, 0x85, 0x51, 0x41, 0x2E, 0x78, 0xB2, 0xE6, 0x91, 0xEC
my_guid_fs: db 0xD4, 0x0B, 0xE9, 0xBF, 0xA7, 0x15, 0xF6, 0x5A
sys: db "sys"
