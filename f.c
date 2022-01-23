int add_lba(int lba, int num) {	
	int s = (lba & 0xff) + num;
	int c = ((lba & 0xffff00) >> 8) + s / 64;
	s -= s / 64 * 64;
	int h = ((lba & 0xff000000) >> 24) + c / 65536;
	c -= c / 65536 * 65536;

	return s | (c << 8) | (h << 24);
}
