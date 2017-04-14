PREFIX = /usr/local
CSC = csc
CSCFLAGS = -optimize-level 3
SRC = slurf.scm
OUT = ${SRC:.scm=}

all: egg slurf

egg:
	@echo Installing ostatus egg and its dependencies.
	chicken-install

slurf:
	@echo Compiling slurf.
	$(CSC) $(CSCFLAGS) $(SRC) -o $(OUT)

install:
	@echo Installing slurf.
	install -D $(OUT) $(PREFIX)/bin

clean:
	@echo Cleaning.
	rm -f *.import.* *.so $(OUT)

.PHONY: all egg install clean
