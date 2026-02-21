# Makefile
.PHONY: test

# Directory to temporarily clone mini.nvim for testing
DEPS_DIR := .tests/deps
MINI_DIR := $(DEPS_DIR)/mini.nvim

$(MINI_DIR):
	@mkdir -p $(DEPS_DIR)
	git clone --depth 1 https://github.com/echasnovski/mini.nvim $(MINI_DIR)

test: $(MINI_DIR)
	@nvim --headless --noplugin -u tests/init.lua -c "lua MiniTest.run()"
