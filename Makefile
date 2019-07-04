PREFIX ?= /usr/local

.PHONY = install
install:
	@cp prm.sh $(PREFIX)/bin
	@echo "prm installed in $(PREFIX)/bin/prm.sh"
