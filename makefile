LIBNAME = clipboard
LUADIR = /usr/local/include/luajit-2.0/

COPT = -O2
# COPT = -DLPEG_DEBUG -g

CWARNS = -Wall -Wextra -pedantic \
	-Waggregate-return \
	-Wcast-align \
	-Wcast-qual \
	-Wdisabled-optimization \
	-Wpointer-arith \
	-Wshadow \
	-Wsign-compare \
	-Wundef \
	-Wwrite-strings \
	-Wbad-function-cast \
	-Wdeclaration-after-statement \
	-Wmissing-prototypes \
	-Wnested-externs \
	-Wstrict-prototypes \
# -Wunreachable-code \


CFLAGS = $(CWARNS) $(COPT) -ansi -I$(LUADIR) -fPIC
CC = gcc

FILES = clipboard.o

# For Linux
linux:
	make clipboard.so "DLLFLAGS = -shared -fPIC"

# For Mac OS
macosx:
	make clipboard.so "DLLFLAGS = -bundle -framework AppKit -framework Cocoa -undefined dynamic_lookup"

clipboard.so: $(FILES)
	env $(CC) $(DLLFLAGS) $(FILES) -o clipboard.so

$(FILES): makefile

test: test.lua re.lua clipboard.so
	./test.lua

clean:
	rm -f $(FILES) clipboard.so


clipboard.o: clipboard.m
# lpcode.o: lpcode.c lptypes.h lpcode.h lptree.h lpvm.h lpcap.h
# lpprint.o: lpprint.c lptypes.h lpprint.h lptree.h lpvm.h lpcap.h
# lptree.o: lptree.c lptypes.h lpcap.h lpcode.h lptree.h lpvm.h lpprint.h
# lpvm.o: lpvm.c lpcap.h lptypes.h lpvm.h lpprint.h lptree.h

