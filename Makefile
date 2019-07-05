PREFIX ?= /usr/local

.PHONY = install
install:
	@cp prm.sh $(PREFIX)/bin
	@echo "prm installed in $(PREFIX)/bin/prm.sh"
	@echo "Remember to add the following alias to your shell configuration file"
	@echo "alias prm=\". $(PREFIX)/bin/prm.sh\""
