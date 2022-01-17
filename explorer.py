import sys
from re import split

fs_num = [0x5a,0xf6,0x15,0xa7,0xbf,0xe9,0x0b,0xd4]
fs_num.reverse()


def lba2addr(lba):
	return (lba[0] | lba[1] << 8 | lba[2] << 16 | lba[3] << 24) * 512


def get_next_free_sector(start, end):
	fst = start

	while fst < end:
		if data[fst] == 0:
			return fst
		
		fst += 512
	
	return None


def get_name(fst):
	if data[fst] != 1 and data[fst] != 2:
		print(fst, "не является ни папкой, но файлом!")
		return
	
	name_len = data[fst+9]

	name = ""

	for i in data[fst+10:fst+10+name_len]:
		name += chr(i)

	return name 


def get_folders(fst):
	folders_count = 0

	if data[fst:fst+8] == fs_num:
		folders_count = data[fst+24]

	elif data[fst] != 1:
		print(fst, "не является папкой!")
		return
	
	else:
		name_len = data[fst+9]
		folders_count = data[fst+9+name_len+1]
	

	res = ""

	for i in range(folders_count):
		res += get_name(lba2addr(data[fst+512+i*8:fst+512+i*8+8])) + " "

	return res


def get_files(fst):
	folders_count = 0
	files_count = 0

	if data[fst:fst+8] == fs_num:
		folders_count = data[fst+24]
		files_count = data[fst+25]

	elif data[fst] != 2:
		print(fst, "не является файлом!")
		return
	
	else:
		name_len = data[fst+9]
		folders_count = data[fst+9+name_len+1]
		files_count = data[fst+9+name_len+2]
	

	res = ""

	for i in range(files_count):
		res += get_name(lba2addr(data[fst+folders_count*8+512+i*8:fst+folders_count*8+512+i*8+8])) + " "

	return res
	

def make_folder(name, fst):
	folders_count = 0


	if data[fst:fst+8] == fs_num:
		data[fst+24] = data[fst+24] + 1
		folders_count = data[fst+24]
	
	elif data[fst] != 1:
		print(fst, "не является папкой!")
		return
	
	else:
		name_len = data[fst+9]
		data[fst+9+name_len+1] = data[fst+9+name_len+1] + 1
		folders_count = data[fst+9+name_len+1]
	

	ffst = get_next_free_sector(fst+512*4,fs[current_fs_id][1]-512*4)

	data[ffst] = 1
	data[ffst + 1] = (fst * 512) & 0xff
	data[ffst + 2] = (fst * 512) >> 8 & 0xff
	data[ffst + 3] = (fst * 512) >> 16 & 0xff
	data[ffst + 4] = (fst * 512) >> 24 & 0xff
	data[ffst + 5] = 0
	data[ffst + 6] = 0
	data[ffst + 7] = 0
	data[ffst + 8] = 0

	data[ffst + 9] = len(name)

	for i in range(len(name)):
		data[ffst + 10 + i] = ord(name[i])
	
	for i in range(512*4):
		data[ffst+512+i]=0xff
	
	for i in range(8):
		data[fst + 512 + folders_count * 8 - 8 + i] = (ffst // 512) >> (i * 8) & 0xff



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
		eoffset = 0
		for j in range(8):
			eoffset |= data[1024 + i * 0x80 + 0x28 + j] << (j * 8)
		fs.append([soffset * 512, eoffset * 512])


if len(fs) == 0:
	print("Не найдено ни одной фаловой системы!")
	exit()


print("Кол-во файловых систем: " + str(len(fs)))

current_fs_id = 0
current_offset = fs[0][0]

while True:
	inp = input("$ ")
	cmd = []

	for i in inp.split(" "):
		if i != "":
			cmd.append(i)
	
	if cmd[0] == "exit":
		break
	
	elif cmd[0] == "help":
		print('exit - выход из программы\n\
sets - выбрать файловую систему\n\
ls - вывод файлов/папок в папке\n\
cd - перейти в другую директорию\n\
load - загрузка файла в папку\n\
mkdir - создание папки\n\
read - чтение файла\n\
rm - удаление файла\n\
rmf - удаление папки')

	elif cmd[0] == "sets":
		if len(cmd) == 1:
			print("Использование: sets <int>")
		
		elif int(cmd[1]) >= len(fs):
			print("Номер файловой системы больше чем кол-во ф.с. - 1")

		else:
			print("Используется фаловая система с номером: " + cmd[1])
			current_fs_id = int(cmd[1])
			current_offset = fs[current_fs_id][0]
	
	elif cmd[0] == "ls":
		if len(cmd) == 1:
			print(get_folders(current_offset) + get_files(current_offset))
	
	elif cmd[0] == "mkdir":
		if len(cmd) == 1:
			print("Использование: mkdir <имена папок>")

		else:
			for i in cmd[1:]:
				make_folder(i, current_offset)		


file = open(file_name, mode="bw")

file.write(bytearray(data))

file.close()
