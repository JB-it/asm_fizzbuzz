.SILENT:
hello:
	echo "Hello, World! From Makefile"

run:
	nasm -f elf64 main.asm 
	ld main.o -o main
	./main