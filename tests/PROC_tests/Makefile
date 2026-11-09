LTP_SRC ?= /home/builder/Repos/ltp

CFLAGS += -Wall -I../include -I$(LTP_SRC)/include -I$(LTP_SRC)/include/old
LDFLAGS += -L$(LTP_SRC)/lib
LDLIBS += -lltp

# Detecta todas las fuentes y  permite invocar objetos individuales
SRCS := $(wildcard *.c)
TARGETS := $(SRCS:.c=)

.PHONY: all clean

# Compila todo con 'make' o 'make all'
all: $(TARGETS)

# regla implicita para compilar individualmente
%: %.c
	$(CC) $(CFLAGS) $(LDFLAGS) $< $(LDLIBS) -o $@



clean:
	rm -f $(TARGETS)