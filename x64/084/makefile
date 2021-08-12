name = func4

$(name):$(name).o circle.o rect.o
	gcc -o $(name) $(name).o circle.o rect.o -no-pie
	./$(name)
	
$(name).o:$(name).asm
	nasm -f elf64 -g -F dwarf $(name).asm -l $(name).lst

circle.o: circle.asm
	nasm -f elf64 -g -F dwarf circle.asm -l circle.lst

rect.o: rect.asm
	nasm -f elf64 -g -F dwarf rect.asm -l rect.lst