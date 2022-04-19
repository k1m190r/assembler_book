NAME = server_nasm
CFILE = cfile

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
	gcc -o $(NAME) $(NAME).o $(CFILE).o -no-pie
	./$(NAME)
	
$(NAME).o:$(NAME).asm
	# grep -v "^%line" | 
	nasm -e $(NAME).asm | grep -v "^$$" | awk $(FIX_ASME) > $(NAME).asme
	nasm -f elf64 -g -F dwarf $(NAME).asm -l $(NAME).lst
	objdump -M intel -d $(NAME).o > $(NAME).objdump

CFILE: $(CFILE)
	gcc -c $(CFILE)


