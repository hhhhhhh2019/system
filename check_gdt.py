import sys
from zlib import crc32


def arr2num(arr: list):
	res = 0

	for i in range(len(arr)):
		res |= (arr[i] & 0xff) << (i * 8)

	return res


def get_header_hash():
	header = data[512:512+92]
	header[0x10 + 0] = 0
	header[0x10 + 1] = 0
	header[0x10 + 2] = 0
	header[0x10 + 3] = 0

	return crc32(bytearray(header))

def get_partion_hash():
	table = data[1024:1024 + arr2num(data[512 + 0x54:512 + 0x54 + 4]) * arr2num(data[512 + 0x50:512 + 0x50 + 4])]
	return crc32(bytearray(table))

H = 16
S = 63

def lba(s,c,h):
	return (c * H + h) * S + s

def sch(nlba):
	c = nlba // (H * S)
	h = (nlba // S) % H
	s = (nlba % S) + 1

	return (s,c,h)

def lba2num(nlba):
	return nlba * 512


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


if not data[512:520] == [69, 70, 73, 32, 80, 65, 82, 84]:
	print("GDT not found")
	exit()

print("Version:", data[512 + 0x8:512 + 0x8 + 4])

print("Header size:", arr2num(data[512 + 0xc:512 + 0xc + 4]))

print("Header hash(read):", arr2num(data[512 + 0x10:512 + 0x10 + 4]))
print("Header hash(count):", get_header_hash())

print("This copy LBA:", lba2num(arr2num(data[512 + 0x18:512 + 0x18 + 8])))
print("Alternate copy LBA:", lba2num(arr2num(data[512 + 0x20:512 + 0x20 + 8])))

print("Start usable LBA:", lba2num(arr2num(data[512 + 0x28:512 + 0x28 + 8])))
print("End usable LBA:", lba2num(arr2num(data[512 + 0x30:512 + 0x30 + 8])))

print("GUID:", hex(arr2num(data[512 + 0x38:512 + 0x38 + 16])))

print("LBA partion entry:", lba2num(arr2num(data[512 + 0x48:512 + 0x48 + 8])))
print("Number of partion entries:", arr2num(data[512 + 0x50:512 + 0x50 + 4]))
print("Size of partion entry:", arr2num(data[512 + 0x54:512 + 0x54 + 4]))

print("Partion entry hash(read):", arr2num(data[512 + 0x58:512 + 0x58 + 4]))
print("Partion entry hash(count):", get_partion_hash())