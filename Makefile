# Makefile for building cpm-scalc on Linux

# Set the path to the CPM emulator. 
# Obtain it from here: https://github.com/jhallen/cpm
CPM=cpm

# Define the assembler and linker. Get Macro80 and Link80 from here:
# http://www.retroarchive.org/cpm/lang/m80.com
# http://www.retroarchive.org/cpm/lang/l80.com
MACRO80=m80
LINK80=l80

NAME=scalc
TARGET=$(NAME).com

all: $(TARGET)

ma.rel: main.asm conio.inc string.inc bdos.inc 
	$(CPM) $(MACRO80) ma.rel=main.asm

co.rel: conio.asm bdos.inc
	$(CPM) $(MACRO80) co.rel=conio.asm

db.rel: dbgutl.asm conio.inc
	$(CPM) $(MACRO80) db.rel=dbgutl.asm

im.rel: intmath.asm 
	$(CPM) $(MACRO80) im.rel=intmath.asm

st.rel: string.asm intmath.inc
	$(CPM) $(MACRO80) st.rel=string.asm

# Note that in the linker command line, main (ma.rel) must come first, and
#   end (e.rel) must come last. main contains the first statements of the
#   program, at 0x100, and end contains the "endprog" symbol that is used
#   to work out the start of heap 
$(TARGET): co.rel ma.rel db.rel im.rel st.rel
	$(CPM) $(LINK80) ma,co,db,im,st,$(NAME)/n/e

clean:
	rm -f $(TARGET) *.rel

