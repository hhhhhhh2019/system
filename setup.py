import sys
from zlib import crc32
from uuid import uuid4

H = 16
S = 63

def lba(s,c,h):
	return (c * H + h) * S + s

def sch(nlba):
	c = nlba // (H * S)
	h = (nlba // S) % H
	s = (nlba % S) + 1

	return (s,c,h)

def num2lba(num):
	#s,c,h = sch(num)
	#return s | (c >> 8) | (h >> 24)
	return num // 512

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

		if not inp[0:delim].isnumeric():
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

def num2size(num):
	if num < 1024 * 1024:
		return str(num / 1024) + "КБ"
	elif num < 1024 * 1024 * 1024:
		return str(num / 1024 / 1024) + "МБ"
	else:
		return str(num / 1024 / 1024 / 1024) + "ГБ"


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

disk_size = len(data)

print("Размер диска: " + num2size(disk_size))

end_lba = disk_size // 512 - 1

print("\n\nНастройка gpt")

data[0x1be + 0] = 0
data[0x1be + 1] = 0 # head
data[0x1be + 2] = 2 # cylinder
data[0x1be + 3] = 0 # sector
data[0x1be + 4] = 0xee # type
data[0x1be + 5] = 0xff # head
data[0x1be + 6] = 0xff # cylinder
data[0x1be + 7] = 0xff # sector
data[0x1be + 8] = 1
data[0x1be + 9] = 0
data[0x1be + 10] = 0
data[0x1be + 11] = 0
data[0x1be + 12] = end_lba & 0xff
data[0x1be + 13] = end_lba >> 8 & 0xff
data[0x1be + 14] = end_lba >> 16 & 0xff
data[0x1be + 15] = end_lba >> 32 & 0xff

data[510] = 0x55
data[511] = 0xaa

GPT_sign = 'EFI PART'
for i in range(8):
	data[512 + i] = ord(GPT_sign[i])

data[512 + 8 + 0] = 0
data[512 + 8 + 1] = 0
data[512 + 8 + 2] = 1
data[512 + 8 + 3] = 0

data[512 + 12 + 0] = 92
data[512 + 12 + 1] = 0
data[512 + 12 + 2] = 0
data[512 + 12 + 3] = 0

data[512 + 16 + 0] = 0 # hash
data[512 + 16 + 1] = 0 # hash
data[512 + 16 + 2] = 0 # hash
data[512 + 16 + 3] = 0 # hash

lba_gpt_header = 1
data[512 + 24 + 0] = lba_gpt_header & 0xff
data[512 + 24 + 1] = lba_gpt_header >> 8 & 0xff
data[512 + 24 + 2] = lba_gpt_header >> 16 & 0xff
data[512 + 24 + 3] = lba_gpt_header >> 24 & 0xff
data[512 + 24 + 4] = 0
data[512 + 24 + 5] = 0
data[512 + 24 + 6] = 0
data[512 + 24 + 7] = 0

lba_copy_gpt_header = end_lba
data[512 + 32 + 0] = lba_copy_gpt_header & 0xff
data[512 + 32 + 1] = lba_copy_gpt_header >> 8 & 0xff
data[512 + 32 + 2] = lba_copy_gpt_header >> 16 & 0xff
data[512 + 32 + 3] = 0#lba_copy_gpt_header >> 24 & 0xff
data[512 + 32 + 4] = 0
data[512 + 32 + 5] = 0
data[512 + 32 + 6] = 0
data[512 + 32 + 7] = 0

lba_start_usable = num2lba(512 * 34)
data[512 + 40 + 0] = lba_start_usable & 0xff
data[512 + 40 + 1] = lba_start_usable >> 8 & 0xff
data[512 + 40 + 2] = lba_start_usable >> 16 & 0xff
data[512 + 40 + 3] = lba_start_usable >> 24 & 0xff
data[512 + 40 + 4] = 0
data[512 + 40 + 5] = 0
data[512 + 40 + 6] = 0
data[512 + 40 + 7] = 0

lba_end_usable = num2lba(disk_size - 512 * 34)
data[512 + 48 + 0] = lba_end_usable & 0xff
data[512 + 48 + 1] = lba_end_usable >> 8 & 0xff
data[512 + 48 + 2] = lba_end_usable >> 16 & 0xff
data[512 + 48 + 3] = lba_end_usable >> 24 & 0xff
data[512 + 48 + 4] = 0
data[512 + 48 + 5] = 0
data[512 + 48 + 6] = 0
data[512 + 48 + 7] = 0

#guid = 0xC12A7328F81F11D2BA4B00A0C93EC93B
guid = int(uuid4())
for i in range(16):
	data[512 + 56 + i] = guid >> (i * 8) & 0xff

lba_table_start = 2
data[512 + 72 + 0] = lba_table_start & 0xff
data[512 + 72 + 1] = lba_table_start >> 8 & 0xff
data[512 + 72 + 2] = lba_table_start >> 16 & 0xff
data[512 + 72 + 3] = lba_table_start >> 24 & 0xff
data[512 + 72 + 4] = 0
data[512 + 72 + 5] = 0
data[512 + 72 + 6] = 0
data[512 + 72 + 7] = 0

data[512 + 80 + 0] = 0
data[512 + 80 + 1] = 0
data[512 + 80 + 2] = 0
data[512 + 80 + 3] = 0

data[512 + 84 + 0] = 0x80
data[512 + 84 + 1] = 0
data[512 + 84 + 2] = 0
data[512 + 84 + 3] = 0

data[512 + 88 + 0] = 0 # table hash
data[512 + 88 + 1] = 0 # table hash
data[512 + 88 + 2] = 0 # table hash
data[512 + 88 + 3] = 0 # table hash


print("\nНастройка разделов\n")

ask = input("Создать разделы на диске? (д/н): ").lower()

sections_count = 0

my_guid = 0xec91e6b2782e415185799aaae1547431

if ask == "y" or ask == "д":
	next_free_sector = 512 * 35
	create_new_section = True
	free_space = disk_size - 512 - (512 + 0x80 * 128) * 2
	print("\nМаксимальное кол-во разделов: 128\nСвободного места: " + num2size(free_space) + "\n")

	while create_new_section:
		size = 0

		while True:
			size = size_input("Размер раздела: ")
			if size > free_space:
				ask = input("Свободного места мень чем размер раздела, устроновить размер в " + num2size(free_space) + "?(д/н): ").lower()

				if ask == "y" or ask == "д":
					size = free_space
					break
			else:
				break

		free_space -= size

		sname = input("Имя раздела(максимум 72 символа): ")

		fstype = -1

		print("Типы файловых систем:\n\t0 - нет файловой системы\n\t1 - моя файловая система")

		while True:
			ask = int_input("Тип файловай системы: ")

			if ask > 1:
				print("Неправильной тип файловой системы!")
				continue
			
			match ask:
				case 0:
					fstype = 0
					break
				case 1:
					fstype = my_guid
			break

		fsguid = fstype
		sguid = int(uuid4())

		for i in range(16):
			data[1024 + sections_count * 128 + i] = fsguid >> (i * 8) & 0xff
		
		for i in range(16):
			data[1024 + sections_count * 128 + 16 + i] = sguid >> (i * 8) & 0xff
		
		start_lba = num2lba(next_free_sector)
		data[1024 + sections_count * 128 + 32 + 0] = start_lba & 0xff
		data[1024 + sections_count * 128 + 32 + 1] = start_lba >> 8 & 0xff
		data[1024 + sections_count * 128 + 32 + 2] = start_lba >> 16 & 0xff
		data[1024 + sections_count * 128 + 32 + 3] = start_lba >> 24 & 0xff
		data[1024 + sections_count * 128 + 32 + 4] = 0
		data[1024 + sections_count * 128 + 32 + 5] = 0
		data[1024 + sections_count * 128 + 32 + 6] = 0
		data[1024 + sections_count * 128 + 32 + 7] = 0

		end_lba = num2lba(next_free_sector + size)
		data[1024 + sections_count * 128 + 40 + 0] = end_lba & 0xff
		data[1024 + sections_count * 128 + 40 + 1] = end_lba >> 8 & 0xff
		data[1024 + sections_count * 128 + 40 + 2] = end_lba >> 16 & 0xff
		data[1024 + sections_count * 128 + 40 + 3] = end_lba >> 24 & 0xff
		data[1024 + sections_count * 128 + 40 + 4] = 0
		data[1024 + sections_count * 128 + 40 + 5] = 0
		data[1024 + sections_count * 128 + 40 + 6] = 0
		data[1024 + sections_count * 128 + 40 + 7] = 0

		data[1024 + sections_count * 128 + 48 + 0] = 0
		data[1024 + sections_count * 128 + 48 + 1] = 0
		data[1024 + sections_count * 128 + 48 + 2] = 0
		data[1024 + sections_count * 128 + 48 + 3] = 0
		data[1024 + sections_count * 128 + 48 + 4] = 0
		data[1024 + sections_count * 128 + 48 + 5] = 0
		data[1024 + sections_count * 128 + 48 + 6] = 0
		data[1024 + sections_count * 128 + 48 + 7] = 0

		next_free_sector += size + 512

		for i in range(min(len(sname), 72)):
			data[1024 + sections_count * 128 + 56 + i] = ord(sname[i])

		sections_count += 1

		if free_space > 0:
			ask = input("Создать еще один раздел? (д/н): ").lower()
			if ask == "y" or ask == "д":
				create_new_section = True
			else:
				create_new_section = False
		else:
			break


data[512 + 80 + 0] = 128 & 0xff
data[512 + 80 + 1] = 128 >> 8 & 0xff
data[512 + 80 + 2] = 128 >> 16 & 0xff
data[512 + 80 + 3] = 128 >> 24 & 0xff


table_hash = int(crc32(bytearray(data[1024:1024 + 128*128])))

data[512 + 88 + 0] = table_hash & 0xff
data[512 + 88 + 1] = table_hash >> 8 & 0xff
data[512 + 88 + 2] = table_hash >> 16 & 0xff
data[512 + 88 + 3] = table_hash >> 24 & 0xff


gpt_hash = int(crc32(bytearray(data[512:512+92])))

data[512 + 16 + 0] = gpt_hash & 0xff
data[512 + 16 + 1] = gpt_hash >> 8 & 0xff
data[512 + 16 + 2] = gpt_hash >> 16 & 0xff
data[512 + 16 + 3] = gpt_hash >> 24 & 0xff


for i in range(512):
	data[disk_size - 512 + i] = data[512 + i]

for i in range(12 * 34):
	data[disk_size - 512 * 34 + i] = data[1024 + i]



file = open(file_name, mode="bw")
file.write(bytearray(data))
file.close()
