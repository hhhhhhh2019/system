import sys

FULL_CLEAR = True

fs_num = [0x5a,0xf6,0x15,0xa7,0xbf,0xe9,0x0b,0xd4]
fs_num.reverse()


H = 16
S = 63

def lba(s,h,c):
	return (c * H + h) * S + (s - 1)

def sch(nlba):
	s = (nlba % S) + 1
	h = (nlba - (s - 1)) // S % H
	c = (nlba - (s - 1) - h * S) // (H * S)

	return (s,h,c)

def num2lba(num):
	return num // 512

def arr2num(arr):
	res = 0

	for i in range(len(arr)):
		res |= arr[i] << (i * 8)
	
	return res

def lba2addr(lba):
	if isinstance(lba, list):
		lba = arr2num(lba)
	s,h,c = sch(lba)
	return ((s - 1)  + h * 63 + c * 63 * 65535) * 512

def add_lba(lba, num):
	s = (lba & 0xff) + num
	c = ((lba & 0xffff00) >> 8) + s // 64
	s -= s // 64 * 64
	h = ((lba & 0xff000000) >> 24) + c // 65536
	c -= c // 65536 * 65536
	return s | (c << 8) | (h << 24)


def get_next_free_sector(start, end):
	fst = start

	while fst < end:
		if data[fst] == 0:
			return fst
		
		fst += 512
	
	return None


def get_name(fst):
	if data[fst] != 1 and data[fst] != 2:
		print(fst, "не является ни папкой, ни файлом!")
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
	

	res = []

	for i in range(folders_count):
		res.append(get_name(lba2addr(data[fst+512+i*8:fst+512+i*8+8])))

	return res


def get_files(fst):
	files_count = 0

	if data[fst:fst+8] == fs_num:
		files_count = data[fst+25]

	elif data[fst] != 1:
		print(fst, "не является папкой!")
		return
	
	else:
		name_len = data[fst+9]
		files_count = data[fst+9+name_len+2]
	

	res = []

	for i in range(files_count):
		res.append(get_name(lba2addr(data[fst+2560+i*8:fst+2560+i*8+8])))

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
	

	ffst = get_next_free_sector(fst+512*8,fs[current_fs_id][1]-512*8)

	data[ffst] = 1
	data[ffst + 1] = num2lba(fst) & 0xff
	data[ffst + 2] = num2lba(fst) >> 8 & 0xff
	data[ffst + 3] = num2lba(fst) >> 16 & 0xff
	data[ffst + 4] = num2lba(fst) >> 24 & 0xff
	data[ffst + 5] = 0
	data[ffst + 6] = 0
	data[ffst + 7] = 0
	data[ffst + 8] = 0

	data[ffst + 9] = len(name)

	for i in range(len(name)):
		data[ffst + 10 + i] = ord(name[i])
	
	for i in range(512*8):
		data[ffst+512+i]=0xff
	
	for i in range(8):
		data[fst + 512 + folders_count * 8 - 8 + i] = num2lba(ffst) >> (i * 8) & 0xff


def remove_folder(name, fst):
	flds = get_folders(fst)

	if not name in flds:
		print("Папка " + name + " не найдена!")
		return
	

	if data[fst:fst+8] == fs_num:
		data[fst+24] = data[fst+24] - 1
	
	else:
		name_len = data[fst+9]
		data[fst+9+name_len+1] = data[fst+9+name_len+1] - 1
	

	fldlink_fst = fst+512+flds.index(name)*8
	

	fld_fst = lba2addr(data[fldlink_fst:fldlink_fst+8])

	tmp = data[fldlink_fst+8:fldlink_fst+8+2048-(fldlink_fst-fst)]
	
	for i in range(len(tmp)):
		data[fldlink_fst + i] = tmp[i]
	
	fst = fld_fst

	while fst < fld_fst + 4096+512:
		data[fst] = 0

		if FULL_CLEAR:
			fst += 1
		else:
			fst += 512


def load_file(name, fst):
	files_count = 0

	if data[fst:fst+8] == fs_num:
		data[fst+25] = data[fst+25] + 1
		files_count = data[fst+25]
	
	elif data[fst] != 1:
		print(fst, "не является папкой!")
		return
	
	else:
		name_len = data[fst+9]
		data[fst+9+name_len+2] = data[fst+9+name_len+2] + 1
		files_count = data[fst+9+name_len+2]

	file = open(name, mode='br')
	fdata = list(file.read())
	file.close()

	fname = name.split("/")[-1]

	ffst = get_next_free_sector(fst+512*8,fs[current_fs_id][1]-512*5)

	print(num2lba(fst))

	data[ffst] = 2
	data[ffst + 1] = num2lba(fst) & 0xff
	data[ffst + 2] = num2lba(fst) >> 8 & 0xff
	data[ffst + 3] = num2lba(fst) >> 16 & 0xff
	data[ffst + 4] = num2lba(fst) >> 24 & 0xff
	data[ffst + 5] = 0
	data[ffst + 6] = 0
	data[ffst + 7] = 0
	data[ffst + 8] = 0

	data[ffst + 9] = len(fname)

	for i in range(len(fname)):
		data[ffst + 10 + i] = ord(fname[i])
	
	for i in range(512*5):
		data[ffst+512+i]=0xff

	for i in range(8):
		data[fst + 2560 + files_count * 8 - 8 + i] = num2lba(ffst) >> (i * 8) & 0xff
	
	ncount = len(fdata)

	while True:
		scount = 0
		sfst = 0
		sbfst = 0

		for i in range(ncount // 512 + 1):
			snfst = get_next_free_sector(fs[current_fs_id][0],fs[current_fs_id][1]-512)

			if sbfst != 0 and snfst - sbfst > 512:
				break
				
			data[snfst] = 0xff
				
			sbfst = snfst

			if scount == 0:
				sfst = snfst
				scount += 1
			else:
				scount += 1
		
		tmp = 0
		
		for i in range(min(len(fdata), scount * 512)):
			data[sfst + i] = fdata[i + len(fdata) - min(len(fdata), ncount)]
			tmp += 1
		
		ncount -= tmp
		
		data[ffst + 10 + len(fname)] = data[ffst + 10 + len(fname)] + 1

		for i in range(8):
			data[ffst + 512 + data[ffst + 10 + len(fname)] * 9 - 9 + i] = (sfst // 512) >> (i * 8) & 0xff
		data[ffst + 512 + data[ffst + 10 + len(fname)] * 9 - 9 + 8] = scount
		
		if ncount == 0:
			break


def read_file(name, fst):
	fls = get_files(fst)

	if not name in fls:
		print("Файл " + name + " не найден!")
		return
	
	fllink_fst = fst+2560+fls.index(name)*8

	ffst = lba2addr(data[fllink_fst:fllink_fst+8])

	segments = []

	for i in range(int(data[ffst + 1 + 8 + len(name) + 1])):
		segments.append([lba2addr(data[ffst + 512 + i * 9:ffst + 512 + i * 9 + 8]), data[ffst + 512 + i * 9 + 8]])

	res = ""

	for i in segments:
		for j in range(512 * i[1]):
			res += chr(data[i[0] + j])

	return res


def remove_file(name, fst):
	fls = get_files(fst)

	if not name in fls:
		print("Файл " + name + " не найден!")
		return
	
	if data[fst:fst+8] == fs_num:
		data[fst+25] = data[fst+25] - 1
	
	elif data[fst] != 1:
		print(fst, "не является папкой!")
		return
	
	else:
		name_len = data[fst+9]
		data[fst+9+name_len+2] = data[fst+9+name_len+2] - 1
	
	fllink_fst = fst+2560+fls.index(name)*8
	

	ffst = lba2addr(data[fllink_fst:fllink_fst+8])

	segments = []

	for i in range(int(data[ffst + 1 + 8 + len(name) + 1])):
		segments.append([lba2addr(data[ffst + 512 + i * 9:ffst + 512 + i * 9 + 8]), data[ffst + 512 + i * 9 + 8]])
	

	for i in segments:
		for j in range(0,512 * i[1], 1 if FULL_CLEAR else 512):
			data[i[0] + j] = 0


	tmp = data[fllink_fst+8:fllink_fst+8+2048-(fllink_fst-fst)+2048]
	
	for i in range(len(tmp)):
		data[fllink_fst + i] = tmp[i]
	
	fst = ffst

	while fst < ffst + 2048:
		data[fst] = 0

		if FULL_CLEAR:
			fst += 1
		else:
			fst += 512


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
		fs.append([lba2addr(soffset), lba2addr(eoffset)])


if len(fs) == 0:
	print("Не найдено ни одной фаловой системы!")
	exit()


print("Кол-во файловых систем: " + str(len(fs)))

current_fs_id = 0
current_offset = fs[0][0]

current_path = "/"

while True:
	inp = input(current_path + "$ ")
	cmd = []

	for i in inp.split(" "):
		if i != "":
			cmd.append(i)
		
	if len(cmd) == 0:
		continue
	
	if cmd[0] == "exit":
		break
	
	elif cmd[0] == "help":
		print('exit - выход из программы\n\
sets - выбрать файловую систему\n\
ls - вывод файлов/папок в папке\n\
cd - перейти в другую директорию\n\
mkdir - создание папки\n\
rmd - удаление папки\n\
load - загрузка файла в папку\n\
read - чтение файла\n\
rm - удаление файла')

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
			print(get_folders(current_offset), get_files(current_offset))
	
	elif cmd[0] == "mkdir":
		if len(cmd) == 1:
			print("Использование: mkdir <имена папок>")

		else:
			for i in cmd[1:]:
				make_folder(i, current_offset)
		
	elif cmd[0] == "rmd":
		if len(cmd) == 1:
			print("Использование: rmd <имена папок>")

		else:
			for i in cmd[1:]:
				remove_folder(i, current_offset)
	
	elif cmd[0] == "cd":
		if len(cmd) == 1:
			current_offset = fs[current_fs_id][0]
			current_path = "/"
		
		elif len(cmd) == 2:
			fst = current_offset

			if cmd[1] == "..":
				if data[fst:fst+8] == fs_num:
					print("Папка в которой вы находитесь является корневой папкой!")
					continue
				
				fld_fst = lba2addr(data[fst+1:fst+9])
				
				current_offset = fld_fst

				split_path = current_path.split("/")

				current_path = "/"

				for i in split_path[:-2]:
					if i != "":
						current_path += i + "/"
			else:
				name = cmd[1]

				flds = get_folders(fst)

				if not name in flds:
					print("Папка " + name + " не найдена!")
					continue
				
				fldlink_fst = fst+512+flds.index(name)*8

				fld_fst = lba2addr(data[fldlink_fst:fldlink_fst+8])

				current_path += name + "/"
				current_offset = fld_fst
	
	elif cmd[0] == "load":
		if len(cmd) != 2:
			print("Использование: load <имя файла>")
			continue
			
		load_file(cmd[1], current_offset)

	elif cmd[0] == "read":
		if len(cmd) != 2:
			print("Использование: read <имя файла>")
			continue
			
		print(read_file(cmd[1], current_offset))
	
	elif cmd[0] == "rm":
		if len(cmd) == 1:
			print("Использование: rm <имена файлов>")

		else:	
			for i in cmd[1:]:
				remove_file(i, current_offset)


file = open(file_name, mode="bw")

file.write(bytearray(data))

file.close()
