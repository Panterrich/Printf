all:		
	nasm -f elf64 $(source).asm
	ld -o $(source) $(source).o
	rm $(source).o

build: 
	nasm -f elf64 -g Printf.asm
	g++ -g -c main.cpp
	g++ -g main.o Printf.o -o printf -no-pie
	rm main.o
	rm Printf.o

Print_c:
	nasm -f elf64 -g Print_c.asm 
	gcc -o Print_c Print_c.o -no-pie
