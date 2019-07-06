# Makefile to make BAISC load image
# 07-04-19 Xark

CFLAGS = -Os -Wall

all:
	./make_basic_programs.sh

extract: split_programs
	rm -rf extracted_programs
	mkdir -p extracted_programs
	cd extracted_programs && ../split_programs ../extracted_programs.rom

split_programs: split_programs.c

clean:
	rm -f basic_programs.rom 00_directory.txt split_programs
