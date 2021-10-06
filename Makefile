BIN ?= ./zig-out/bin/rotate
EXPORT_FILES = std.c std.h *.c *.h

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
	@rm -rf ./zig-out/ ./zig-cache/ *.md callgrind.out* $(EXPORT_FILES)

analyze:
	@valgrind --tool=callgrind $(BIN)
	@kcachegrind
