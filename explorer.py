import sys
from re import split



my_guid = 0xec91e6b2782e415185799aaae1547431


file_name = ''

if len(sys.argv) > 1:
	file_name = sys.argv[1]
	print("Образ диска: " + str(file_name))
else:
	file_name = input("Образ диска: ")

print("")

file = open(file_name, mode="br")

data = list(file.read())

file.close()

fs = []

sections_count = data[512 + 80 + 0] | data[512 + 80 + 1] << 8 | data[512 + 80 + 2] << 16 | data[512 + 80 + 3] << 24

for i in range(sections_count):
	sguid = 0
	for j in range(16):
		sguid |= data[1024 + i * 0x80 + j] << (j * 8)
	
	if sguid == my_guid + 2:
		soffset = 0
		for j in range(8):
			soffset |= data[1024 + i * 0x80 + 0x20 + j] << (j * 8)
		fs.append(soffset * 512)


if len(fs) == 0:
	print("Не найдено ни одной фаловой системы!")
	exit()


print("Кол-во файловых систем: " + len(fs))

current_fs_id = 0

while True:
	inp = input("$ ")
	cmd = []

	for i in split(" \t\n"):
		if i != "":
			cmd.append(i)
	
	if cmd[0] == "exit":
		break


file = open(file_name, mode="bw")

file.write(bytearray(data))

file.close()