name = memory

$(name):$(name).o
	gcc -o $(name) $(name).o -no-pie
	./$(name)
	
$(name).o:$(name).asm
	nasm -f elf64 -g -F dwarf $(name).asm -l $(name).lst