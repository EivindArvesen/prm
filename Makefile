PREFIX ?= /usr/local

.PHONY: install
install:
	@cp prm.sh $(PREFIX)/bin
	@echo "prm installed in $(PREFIX)/bin/prm.sh"
	@echo "Remember to add the following alias to your shell configuration file."
	@echo "alias prm=\". $(PREFIX)/bin/prm.sh\""

.PHONY: uninstall
uninstall:
	@rm -f $(PREFIX)/bin/prm.sh
	@echo "prm removed from $(Prefix)/BIn"
	@echo "Remember to remove the alias from your shell configuration file."

test:
	@bash tests/run-tests.sh
