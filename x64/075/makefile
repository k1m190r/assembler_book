NAME = main
CFILE = showip

# indent line if it starts with "%line"
SPACES = "                              "
FIX_ASME = '                       \
{                                  \
	if ($$1 == "%line")            \
		print $(SPACES), $$0 ;     \
	else                           \
		print $$0;                 \
};                                 \
' 

$(NAME):$(NAME).o $(CFILE).o

	# compile into non positionally independant executable
	gcc -o out/$(NAME) out/$(NAME).o out/$(CFILE).o -no-pie

	# RUN it
	./out/$(NAME) google.com
	
$(NAME).o:$(NAME).asm

	# preprocess only| remove empty lines| 
	nasm -e $(NAME).asm | grep -v "^$$" | awk $(FIX_ASME) > out/$(NAME).asme

	# compile and produce a listing
	nasm -o out/$(NAME).o -f elf64 -g -F dwarf $(NAME).asm -l out/$(NAME).lst

	# make an object dump
	objdump -M intel -d out/$(NAME).o > out/$(NAME).objdump

$(CFILE).o: $(CFILE).c

	# compile into obj 
	gcc -o out/$(CFILE).o -c $(CFILE).c

	# produce objdump
	objdump -M intel -d out/$(CFILE).o > out/$(CFILE).objdump


