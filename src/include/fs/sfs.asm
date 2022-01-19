; int* header
get_fs_data:
	push ebp



	pop ebp
ret

fs_guid: db 0x5af615a7bfe90bd4
my_guid: db 0xec91e6b2782e415185799aaae1547431


heap: times 512 db 0