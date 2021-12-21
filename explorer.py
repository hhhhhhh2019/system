from os.path import exists
import sys


def get_name(fst):
	if data[fst] == 0:
		return None
	
	name_len = data[fst + 5]

	return ''.join([chr(x) for x in data[fst + 6:fst + 6 + name_len]])

def get_folder_fst(nfst, name):
	if name == '':
		return sections[section][0] + 512

	if data[nfst] != 1:
		return None
	
	if name == "..":
		fst = data[nfst + 2] * 512 * 256 * 256 + data[nfst + 3] * 512 * 256 + (data[nfst + 4] - 1) * 512
		if fst == 0:
			return nfst
		return fst
	
	name_len = data[nfst + 5]
	files_count = data[nfst + 5 + name_len + 1]
	folders_count = data[nfst + 5 + name_len + 2]
	
	for i in range(folders_count):
		head = data[nfst + 5 + name_len + 3 + files_count * 3 + i * 3 + 0]
		cylinder = data[nfst + 5 + name_len + 3 + files_count * 3 + i * 3 + 1]
		sector = data[nfst + 5 + name_len + 3 + files_count * 3 + i * 3 + 2]

		fst = head * 512 * 256 * 256 + cylinder * 512 * 256 + (sector - 1) * 512

		if get_name(fst) == name:
			return fst
	
	return None

def get_file_fst(nfst, name):
	if data[nfst] != 1:
		return None
	
	if name == '':
		return sections[section][0] + 512
	
	if name == "..":
		fst = data[nfst + 2] * 512 * 256 * 256 + data[nfst + 3] * 512 * 256 + (data[nfst + 4] - 1) * 512
		if fst == 0:
			return nfst
		return fst
	
	name_len = data[nfst + 5]
	files_count = data[nfst + 5 + name_len + 1]
	
	for i in range(files_count):
		head = data[nfst + 5 + name_len + 3 + i * 3 + 0]
		cylinder = data[nfst + 5 + name_len + 3 + i * 3 + 1]
		sector = data[nfst + 5 + name_len + 3 + i * 3 + 2]

		fst = head * 512 * 256 * 256 + cylinder * 512 * 256 + (sector - 1) * 512

		if get_name(fst) == name:
			return fst
	
	return None

def get_next_free_sector(start, end):
	fst = start

	while fst < end:
		if data[fst] == 0:
			return fst
		
		fst += 512
	
	return None

def get_files(folder_fst=None):
	if folder_fst == None:
		folder_fst = now_fld_offset

	name_len = data[folder_fst + 5]
	files_count = data[folder_fst + 5 + name_len + 1]

	text = ""

	for i in range(files_count):
		head = data[folder_fst + 5 + name_len + 3 + i * 3 + 0]
		cylinder = data[folder_fst + 5 + name_len + 3 + i * 3 + 1]
		sector = data[folder_fst + 5 + name_len + 3 + i * 3 + 2]

		fst = head * 512 * 256 * 256 + cylinder * 512 * 256 + (sector - 1) * 512 
		text += str(get_name(fst)) + " "
	
	return text

def get_folders(folder_fst=None):
	if folder_fst == None:
		folder_fst = now_fld_offset

	name_len = data[folder_fst + 5]
	files_count = data[folder_fst + 5 + name_len + 1]
	folders_count = data[folder_fst + 5 + name_len + 2]

	text = ""

	for i in range(folders_count):
		head = data[folder_fst + 5 + name_len + 3 + files_count * 3 + i * 3 + 0]
		cylinder = data[folder_fst + 5 + name_len + 3 + files_count * 3 + i * 3 + 1]
		sector = data[folder_fst + 5 + name_len + 3 + files_count * 3 + i * 3 + 2]

		fst = head * 512 * 256 * 256 + cylinder * 512 * 256 + (sector - 1) * 512 
		text += str(get_name(fst)) + " "
	
	return text

def remove_file(path, fst=None):
	if fst == None:
		fst = now_fld_offset
	
	exists = True
	ffst = fst

	for i in path:
		new_fst = get_file_fst(fst, i)

		if new_fst == None:
			print("Файла" + str(path) + "не существует!")
			exists = False
			break
			
		fst = new_fst
	
	if exists == False:
		return

	
	self_name_len = data[fst + 5]
	fragments = data[fst + 6 + self_name_len]

	data[fst] = 0

	for i in range(fragments):
		length = data[fst + 6 + self_name_len + 1 + i * 4 + 3]
		head = data[fst + 6 + self_name_len + 1 + i * 4 + 0]
		cylinder = data[fst + 6 + self_name_len + 1 + i * 4 + 1]
		sector = data[fst + 6 + self_name_len + 1 + i * 4 + 2]

		for j in range(length):
			sfst = head * 512 * 256 * 256 + cylinder * 512 * 256 + (sector - 1 + j) * 512

			data[sfst] = 0


def remove_folder(path, fst=None):
	if fst == None:
		fst = now_fld_offset
	
	exists = True
	#ffst = fst

	for i in path:
		new_fst = get_folder_fst(fst, i)

		if new_fst == None:
			print("Папки" + str(path) + "не существует!")
			exists = False
			break
			
		fst = new_fst
	
	if exists == False:
		return

	flds = get_folders(fst).split(" ")
	flds = [i for i in flds if i != '']

	if len(flds) > 0:
		for i in flds:
			remove_folder([i], fst)
	
	fles = get_files(fst).split(" ")
	fles = [i for i in fles if i != '']

	if len(fles) > 0:
		for i in fles:
			remove_file([i], fst)
	
	data[fst] = 0

	pfst = data[fst + 2] * 512 * 256 * 256 + data[fst + 3] * 512 * 256 + (data[fst + 4] - 1) * 512

	pname_len = data[pfst + 5]
	pfiles = data[pfst + 5 + pname_len + 1]
	pfolders = data[pfst + 5 + pname_len + 2]

	data[pfst + 5 + pname_len + 3 + pfiles * 3 + pfolders * 3] = 0
	data[pfst + 5 + pname_len + 3 + pfiles * 3 + pfolders * 3 + 1] = 0
	data[pfst + 5 + pname_len + 3 + pfiles * 3 + pfolders * 3 + 2] = 0

	data[pfst + 5 + pname_len + 2] -= 1

def load_file(name):
	if not exists(name):
		print("Файл " + name + " не найден!")
		return
	
	fname = name.split('/')[-1]

	file = open(name, "rb")
	fdata = list(file.read())
	file.close()

	fst = get_next_free_sector(sections[section][0], sections[section][1])

	if fst == None:
		print("Не достаточно памяти!")
		return

	#create file

	data[fst] = 2

	data[fst + 1] = 0

	data[fst + 2] = int(now_fld_offset / 512 / 256 / 256)
	data[fst + 3] = int(now_fld_offset / 512 / 256) % 256
	data[fst + 4] = int(now_fld_offset / 512) % 255 + 1

	data[fst + 5] = len(fname)
	for j in range(len(fname)):
		data[fst + 6 + j] = ord(fname[j])
	data[fst + 6 + len(fname)] = 0
	
	name_len = data[now_fld_offset + 5]
	files_count = data[now_fld_offset + 5 + name_len + 1]
	folders_count = data[now_fld_offset + 5 + name_len + 2]

	tmp = data[now_fld_offset + 5 + name_len + 3:now_fld_offset + 5 + name_len + 3 + files_count * 3 + folders_count * 3]

	head = int(fst / 512 / 256 / 256)
	cylinder = int(fst / 512 / 256) % 256
	sector = int(fst / 512) % 255 + 1

	data[now_fld_offset + 5 + name_len + 3 + 0] = head
	data[now_fld_offset + 5 + name_len + 3 + 1] = cylinder
	data[now_fld_offset + 5 + name_len + 3 + 2] = sector

	data[now_fld_offset + 5 + name_len + 1] += 1

	for i in range(len(tmp)):
		data[now_fld_offset + 5 + name_len + 3 + 3 + i] = tmp[i]
	

	#load file data
	dfst = 0
	sectors = 0
	dsize = len(fdata)
	dsize_in_sec = int(dsize / 512) + 1

	last_fst = 0

	while dsize_in_sec > 0:
		nfst = get_next_free_sector(sections[section][0], sections[section][1])
		data[nfst] = 1

		if last_fst != 0 and nfst - last_fst > 512:
			data[fst + 6 + len(fname) + data[fst + 6 + len(fname)] * 4 + 4] = sectors
			data[fst + 6 + len(fname)] += 1
			for i in range(sectors * 512):
				if dsize >= 0:
					data[dfst + i] = fdata[len(fdata) - dsize]
					dsize -= 1
				else:
					data[dfst + i] = 0
			sectors = 0

		if sectors == 0:
			dfst = nfst
			data[fst + 6 + len(fname) + data[fst + 6 + len(fname)] * 4 + 1] = int(dfst / 512 / 256 / 256)
			data[fst + 6 + len(fname) + data[fst + 6 + len(fname)] * 4 + 2] = int(dfst / 512 / 256) % 256
			data[fst + 6 + len(fname) + data[fst + 6 + len(fname)] * 4 + 3] = int(dfst / 512) % 255 + 1

		
		sectors += 1

		dsize_in_sec -= 1

		last_fst = nfst
	
	if sectors > 0:
		data[fst + 6 + len(fname) + data[fst + 6 + len(fname)] * 4 + 4] = sectors
		data[fst + 6 + len(fname)] += 1
		for i in range(sectors * 512):
			data[dfst + i] = fdata[len(fdata) - dsize]
			dsize -= 1
			if dsize == 0:
				break

def read_file(fst):
	if data[fst] != 2:
		return None
	
	name_len = data[fst + 5]
	frag_count = data[fst + 6 + name_len]

	text = ""

	for i in range(frag_count):
		sfst = data[fst + 6 + name_len + 1 + i * 4 + 0] * 512 * 256 * 256 + data[fst + 6 + name_len + 1 + i * 4 + 1] * 512 * 256 + (data[fst + 6 + name_len + 1 + i * 4 + 2] - 1) * 512
		for i in data[sfst:sfst + data[fst + 6 + name_len + 1 + i * 4 + 3] * 512]:
			text += chr(i)
	
	return text


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


sections = []

while True:
	fst = 446 + len(sections) * 16
	
	if data[fst + 4] != 0:
		sfst = data[fst + 1] * 512 * 256 * 256 + data[fst + 2] * 512 * 256 + (data[fst + 3] - 1) * 512
		
		efst = data[fst + 5] * 512 * 256 * 256 + data[fst + 6] * 512 * 256 + (data[fst + 7] - 1) * 512
		
		size = efst - sfst
		
		sections.append([sfst, efst, size])
	else:
		break

fs = []

for i in sections:
	fst = i[0]
	
	fstype = data[fst] | data[fst + 1] << 8
	
	if fstype == 0:
		continue
	
	efst = data[fst + 2] * 512 * 256 * 256 + data[fst + 3] * 512 * 256 + (data[fst + 4] - 1) * 512
	
	ssize = data[fst + 5] | data[fst + 6] << 8 | data[fst + 7] << 16 | data[fst + 8] << 24
	
	fs.append([fstype, efst, ssize])


section = 0
now_fld_offset = sections[0][0] + 512

while True:
	cmd = input("> ")
	cmds = []
	
	for i in cmd.split(" "):
		if i != "" and i != "\t" and i != " ":
			cmds.append(i)
	
	if cmds[0] == "exit":
		break
	
	elif cmds[0] == "help":
		print('exit - выход из программы\n\
list - вывести список разделов\n\
sets - выбрать раздел\n\
ls - вывод файлов/папок в папке\n\
cd - перейти в другую директорию\n\
load - загрузка файла в папку\n\
mkdir - создание папки\n\
read - чтение файла\n\
rm - удаление файла\n\
rmf - удаление папки')
	
	elif cmds[0] == "list":
		for i in sections:
			ssize = ""
			
			if i[2] < 1024 * 1024:
				ssize = str(i[2] / 1024) + "КБ"
			elif i[2] < 1024 * 1024 * 1024:
				ssize = str(i[2] / 1024 / 1024) + "МБ"
			else:
				ssize = str(i[2] / 1024 / 1024 / 1024) + "ГБ"
			
			print("Раздел " + str(sections.index(i)) + ", размер: " + ssize)
	
	elif cmds[0] == "sets":
		if len(cmds) != 2:
			print("Использование: sets <число>")
			continue
		
		if not int(cmds[1]) in range(len(sections)):
			print("Этого раздела не существует!")
			continue
		
		section = int(cmds[1])
		now_fld_offset = sections[section][0] + 512
	
	elif cmds[0] == "ls":
		print(get_files() + get_folders())
	
	elif cmds[0] == "cd":
		if len(cmds) != 2:
			print("Использование: cd <путь(напрмер: /home/usr/fld)>")
			continue

		path_nf = cmds[1].split("/")

		path = [path_nf[0]]

		for i in path_nf[1:]:
			if i != "":
				path.append(i)

		now_fst = now_fld_offset

		for i in path:
			new_fst = get_folder_fst(now_fld_offset, i)

			if new_fst == None:
				print("Папки " + cmds[1] + " не существует!")
				now_fld_offset = now_fst
				break
				
			now_fld_offset = new_fst
	
	elif cmds[0] == "mkdir":
		if len(cmds) == 1:
			print("Использование: mkdir <имена папок>")
			continue
		
		for i in range(len(cmds[1:len(cmds)])):
			fst = get_next_free_sector(sections[section][0], sections[section][1])

			if fst == None:
				print("Не достаточно памяти!")
				break

			data[fst] = 1

			data[fst + 1] = 0

			data[fst + 2] = int(now_fld_offset / 512 / 256 / 256)
			data[fst + 3] = int(now_fld_offset / 512 / 256) % 256
			data[fst + 4] = int(now_fld_offset / 512) % 255 + 1

			data[fst + 5] = len(cmds[i + 1])
			for j in range(len(cmds[i + 1])):
				data[fst + 6 + j] = ord(cmds[i + 1][j])
			
			name_len = data[now_fld_offset + 5]
			files_count = data[now_fld_offset + 5 + name_len + 1]
			folders_count = data[now_fld_offset + 5 + name_len + 2]

			#tmp = data[now_fld_offset + 5 + name_len + 3:now_fld_offset + 5 + name_len + 3 + files_count * 3 + (folders_count - 1) * 3] for files

			head = int(fst / 512 / 256 / 256)
			cylinder = int(fst / 512 / 256) % 256
			sector = int(fst / 512) % 255 + 1

			data[now_fld_offset + 5 + name_len + 3 + files_count * 3 + folders_count * 3 + 0] = head
			data[now_fld_offset + 5 + name_len + 3 + files_count * 3 + folders_count * 3 + 1] = cylinder
			data[now_fld_offset + 5 + name_len + 3 + files_count * 3 + folders_count * 3 + 2] = sector

			data[now_fld_offset + 5 + name_len + 2] += 1
	
	elif cmds[0] == "rmf":
		if len(cmds) == 1:
			print("Использование: rmf <имена папок>")
			continue

		for i in range(len(cmds) - 1):
			remove_folder(cmds[i + 1].split("/"))
	
	elif cmds[0] == "load":
		if len(cmds) == 1:
			print("Использование: load <имена файлов>")
			continue
			
		for i in range(len(cmds) - 1):
			load_file(cmds[i + 1])
	
	elif cmds[0] == "rm":
		if len(cmds) == 1:
			print("Использование: rm <имена файлов>")
			continue

		for i in range(len(cmds) - 1):
			remove_file(cmds[i + 1].split("/"))
	
	elif cmds[0] == "read":
		if len(cmds) != 2:
			print("Использование: read <имя файла>")
			continue

		path_nf = cmds[1].split("/")

		path = [path_nf[0]]

		for i in path_nf[1:-1]:
			if i != "":
				path.append(i)
			
		now_fst = now_fld_offset

		for i in path:
			new_fst = get_folder_fst(now_fld_offset, i)

			if new_fst == None:
				now_fld_offset = now_fst
				break
				
			now_fld_offset = new_fst
		
		if not cmds[1].split("/")[-1] in get_files():
			print("Файла " + cmds[1] + " не существует!")
		else:
			print(read_file(get_file_fst(now_fld_offset, cmds[1].split("/")[-1])))
		
		now_fld_offset = now_fst


file = open(file_name, mode="bw")

file.write(bytearray(data))

file.close()

print("")