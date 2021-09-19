BIN ?= ./zig-out/bin/rotate

fast: fmt
	@zig build -Drelease-fast=true run

#	@cat main.c

build: fmt
	@zig build -Drelease-fast=true

test: fmt
	@zig build test

fmt:
	@zig fmt .

clean:
	@rm -rf ./zig-out/ ./zig-cache/ output.md callgrind.out*

analyze:
	@valgrind --tool=callgrind $(BIN) 
	@kcachegrind
