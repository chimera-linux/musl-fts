VERSION  = 1.2.7
CC      ?= cc
AR      ?= ar
CFLAGS  ?= -O2
PREFIX  ?= /usr/local
BINDIR  ?= $(PREFIX)/bin
INCDIR  ?= $(PREFIX)/include
LIBDIR  ?= $(PREFIX)/lib
MANDIR  ?= $(PREFIX)/share/man/man3
EXTRA_CFLAGS = -I. -Wall -Wextra -fPIC

OBJS = fts.o

SOBASE = libfts.so
SONAME = $(SOBASE).0

SLIB = libfts.a
DLIB = $(SONAME).0.0

.PHONY: clean

all: $(SLIB) $(DLIB) musl-fts.pc

.c.o:
	$(CC) -c -o $@ $< $(EXTRA_CFLAGS) $(CFLAGS)

$(SLIB): $(OBJS)
	$(AR) -rcs $(SLIB) $(OBJS)

$(DLIB): $(OBJS)
	$(CC) $(EXTRA_CFLAGS) $(CFLAGS) $(LDFLAGS) $(OBJS) \
		-shared -Wl,-soname,$(SONAME) -o $(DLIB)

musl-fts.pc: musl-fts.pc.in
	sed -e "s,@prefix@,$(PREFIX)," \
		-e 's,@exec_prefix@,$$\{prefix\},' \
		-e 's,@libdir@,$$\{exec_prefix\}/lib,' \
		-e 's,@includedir@,$$\{prefix\}/include,' \
		-e "s,@VERSION@,$(VERSION)," musl-fts.pc.in > musl-fts.pc

clean:
	rm -f $(OBJS) $(SLIB) $(DLIB) musl-fts.pc

install: $(SLIB) $(DLIB)
	install -d $(DESTDIR)$(LIBDIR)
	install -m 755 $(DLIB) $(DESTDIR)$(LIBDIR)/$(DLIB)
	install -m 644 $(SLIB) $(DESTDIR)$(LIBDIR)/$(SLIB)
	ln -sf $(DLIB) $(DESTDIR)$(LIBDIR)/$(SONAME)
	ln -sf $(DLIB) $(DESTDIR)$(LIBDIR)/$(SOBASE)
	install -d $(DESTDIR)$(INCDIR)
	install -m 644 fts.h $(DESTDIR)$(INCDIR)/fts.h
	install -m 644 musl-fts.pc $(DESTDIR)$(LIBDIR)/pkgconfig/musl-fts.pc
	install -m 644 fts.3 $(DESTDIR)$(MANDIR)/fts.3
