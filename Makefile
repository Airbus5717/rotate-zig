BIN ?= ./zig-out/bin/rotate

run: fmt
	@zig build run

fast: fmt
	@zig build -Drelease-fast=true run

build: fmt
	@zig build -Drelease-fast=true

test: fmt
	@zig build test

fmt:
	@zig fmt .

clean:
	@rm -rf ./zig-out/ ./zig-cache/ output.md callgrind.out* main.c

analyze:
	@valgrind --tool=callgrind $(BIN)
	@kcachegrind
