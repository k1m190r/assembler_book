name = func5

$(name):$(name).o
	gcc -o $(name) $(name).o -no-pie
	./$(name)
	
$(name).o:$(name).asm
	# grep -v "^%line" | 
	nasm -e $(name).asm | grep -v "^$$" | awk '{ if ($$1 == "%line") print "\n                            ", $$0, "\n" ; else print $$0; }' > $(name).asme
	nasm -f elf64 -g -F dwarf $(name).asm -l $(name).lst
