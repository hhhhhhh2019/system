from os.path import getsize
import sys


def size_input(ask):
	ok = False
	
	while not ok:
		inp = input(ask)
	
		delim = 0
	
		for i in inp:
			if not i.isnumeric():
				break
			
			delim += 1
		
		if inp == '':
			ok = False
			continue
		
		num = int(inp[0:delim])
		unit = inp[delim:len(inp)].lower()
		
		ok = True
		
		if unit == "":
			ok == False
			continue
		elif unit == "kb" or unit == "кб":
			num *= 1024
		elif unit == "mb" or unit == "мб":
			num *= 1024 * 1024
		elif unit == "gb" or unit == "гб":
			num *= 1024 * 1024 * 1024
		else:
			print("Неизвестный тип!")
			ok = False
			continue
	
	return num


def int_input(ask, mi=0, ma=0):
	res = ""
	in_range = True

	while not res.isnumeric() or not in_range or res == '':
		if not res == "" and not res.isnumeric():
			print("Введите целое число!")
		
		res = input(ask)

		if res == '':
			continue

		if res.isnumeric() and mi != 0 and ma != 0:
			if not (mi >= int(res) >= ma):
				print("Число должно быть в диапозоне от: " + str(mi) + ' - ' + str(ma))
				in_range = False
				continue
			else:
				in_range = True

	return int(res)


def make_simple_fs(offset, msize):
	label = input("Метка тома: ")
	size = size_input("Размер: ")
	if size > msize:
		print("Размер раздела меньше! Размер ф.с. установлен в ", msize)
		size = msize

	data[offset] = 1
	data[offset + 1] = 0
	
	head_end = int((offset + size) / 512 / 256 / 256)
	cylinder_end = int((offset + size) / 512 / 256) % 256
	sector_end = int((offset + size) / 512) % 255 + 1
	
	data[offset + 2] = head_end
	data[offset + 3] = cylinder_end
	data[offset + 4] = sector_end
	
	size_sectors = int(size / 512)
	
	data[offset + 5] = (size_sectors & 0x000000ff)
	data[offset + 6] = (size_sectors & 0x0000ff00) >> 8
	data[offset + 7] = (size_sectors & 0x00ff0000) >> 8 >> 8
	data[offset + 8] = (size_sectors & 0xff000000) >> 8 >> 8 >> 8
	
	
	data[offset + 512] = 1
	data[offset + 512 + 1] = 0
	data[offset + 512 + 2] = 0
	data[offset + 512 + 3] = 0
	data[offset + 512 + 4] = 0
	data[offset + 512 + 5] = len(label)
	for i in range(len(label)):
		data[offset + 512 + 6 + i] = ord(label[i])
	data[offset + 512 + 7 + len(label)] = 0
	data[offset + 512 + 8 + len(label)] = 0


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

disk_size = getsize(file_name)

if disk_size < 1024 * 1024:
	print("Размер диска: "  + str(disk_size / 1024) + "КБ")
elif disk_size < 1024 * 1024 * 1024:
	print("Размер диска: "  + str(disk_size / 1024 / 1024) + "МБ")
else:
	print("Размер диска: "  + str(disk_size / 1024 / 1024 / 1024) + "ГБ")


print("\nСоздание разделов:\n")

section_count = 0

next_pos = 512

free_size = disk_size - 512

add_sections = input("Содать разделы на диске?(д/н): ")

while section_count < 4 and free_size > 0 and (add_sections == 'y' or add_sections == 'д'):
	size = 0

	while True:
		is_boot = input("Загрузочный раздел(д/н): ")

		size = size_input("Размер раздела: ")

		if free_size < size:
			print("Недостаточно памяти!")
			ask = input("Установить размер в " + str(free_size) + "?(д/н): ")
			if ask == "y" or ask == "д":
				size = free_size
				break
			continue
		
		if not size % 512 == 0:
			size = int(size / 512) * 512
		
		break

	free_size -= size

	head = int(next_pos / 512 / 256 / 256)
	cylinder = int(next_pos / 512 / 256) % 256
	sector = int(next_pos / 512) % 255 + 1

	if is_boot == 'y' or is_boot == 'д':
		data[section_count * 16 + 446] = 0x80
	else:
		data[section_count * 16 + 446] = 0
	data[section_count * 16 + 446 + 1] = head
	data[section_count * 16 + 446 + 2] = cylinder
	data[section_count * 16 + 446 + 3] = sector

	data[section_count * 16 + 446 + 5] = head + int(size / 512 / 256 / 256)
	data[section_count * 16 + 446 + 6] = cylinder + int(size / 512 / 256) % 256
	data[section_count * 16 + 446 + 7] = sector + int(size / 512) % 255 + 1

	data[section_count * 16 + 446 + 4] = int_input("Тип раздела(см. Википедию): ")

	first_sec_pos = int(next_pos / 512)
	data[section_count * 16 + 446 + 8] =  first_sec_pos & 0x000000ff
	data[section_count * 16 + 446 + 9] =  (first_sec_pos & 0x0000ff00) >> 8
	data[section_count * 16 + 446 + 10] = (first_sec_pos & 0x00ff0000) >> 8 >> 8
	data[section_count * 16 + 446 + 11] = (first_sec_pos & 0xff000000) >> 8 >> 8 >> 8
	
	sect_size = int(size / 512) - 1
	data[section_count * 16 + 446 + 12] =  sect_size & 0x000000ff
	data[section_count * 16 + 446 + 13] =  (sect_size & 0x0000ff00) >> 8
	data[section_count * 16 + 446 + 14] = (sect_size & 0x00ff0000) >> 8 >> 8
	data[section_count * 16 + 446 + 15] = (sect_size & 0xff000000) >> 8 >> 8 >> 8


	section_count += 1
	next_pos += size

	if free_size == 0:
		break

	cont = input("Продолжить ввод(д/н): ")

	if not cont == 'д' and not cont == 'y':
		break

	print("")


print("\nНастройка файловых систем:")

print("\nТипы:\n\t0 - нет файловой системы\n\t1 - простая файловая система\n")

add_fs = input("Настроить файловые системы?(д/н): ")

if add_fs == 'y' or add_fs == 'д':
	for i in range(section_count):
		type = int_input("Раздел: " + str(i) + "\t тип файловой системы: ", 1, 1)

		sec_fst = data[446 + i * 16 + 1] * 512 * 256 * 256 + data[446 + i * 16 + 2] * 512 * 256 + (data[446 + i * 16 + 3] - 1) * 512
		sec_fst_end = data[446 + i * 16 + 5] * 512 * 256 * 256 + data[446 + i * 16 + 6] * 512 * 256 + (data[446 + i * 16 + 7] - 1) * 512
		sec_size = sec_fst_end - sec_fst

		if type == 1:
			make_simple_fs(sec_fst, sec_size)



file = open(file_name, mode="bw")

file.write(bytearray(data))

file.close()

print("")