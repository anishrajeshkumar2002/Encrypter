# version 1.0
# if you type 'make' without arguments, this is the default
PROG = encrypter
all: $(PROG)

# other source files and the associated object files (this can be blank) SRC is unused here
SRC	= main.s cipher.s setup.c
HEAD	= encrypter.h
OBJ	= main.o cipher.o setup.o

# Names of the test files
ENCR	= ENCRYPTED
OUT	= CLEARTEXT
BOOK	= BOOK
MESSAGE	= MESSAGE

# special libraries
LIB	=

# select the compiler and flags yopu can over-ride on command line e.g. make DEBUG= 
CC	= gcc
DEBUG	= -ggdb
CSTD	= -std=gnu17
WARN	= -Wall -Wextra
CDEFS	=
CFLAGS	= -I. $(DEBUG) $(WARN) $(CSTD) $(CDEFS)

# select the assembler, specify how to generate a .o from a .s and flags
AS	= gcc
ASLIST	= -Wa,-adhln
ASFLAGS = -I. $(DEBUG)

%.o : %.s
	$(AS) -c $(ASFLAGS) $< -o $@

# how to get an object dump of the target
DUMP	= objdump
DFLAGS	= -d

$(OBJ):	$(HEAD)

# specify how to compile the target
$(PROG):	$(OBJ)
	$(CC) $(CFLAGS) $(OBJ) $(LIB) -o $@

# test the program
test:	$(PROG)
	rm -f $(OUT)
	./$(PROG) -e -b $(BOOK) $(ENCR) < $(MESSAGE)
	./$(PROG) -d -b $(BOOK) $(ENCR) > $(OUT)
	diff $(MESSAGE) $(OUT)

# get an object dump
dump:	$(PROG)
	$(DUMP) $(DFLAGS) $^

# remove binaries
.PHONY: clean clobber
clean:
	rm -f $(OBJ) $(PROG) $(OUT) $(ENCR)

# remove binaries and other junk
clobber: clean
	rm -f core
