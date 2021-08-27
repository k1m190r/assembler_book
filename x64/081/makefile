name = bits1

spaces = "                              "
fix_asme = '                       \
{                                  \
	if ($$1 == "%line")            \
		print $(spaces), $$0 ;     \
	else                           \
		print $$0;                 \
};                                 \
' 

$(name):$(name).o printb.o
	gcc -o $(name) $(name).o printb.o -no-pie
	./$(name)
	
$(name).o:$(name).asm
	# grep -v "^%line" | 
	nasm -e $(name).asm | grep -v "^$$" | awk $(fix_asme)> $(name).asme
	nasm -f elf64 -g -F dwarf $(name).asm -l $(name).lst
	objdump -M intel -d $(name).o > $(name).objdump

printb: printb.c
	gcc -c printb.c


