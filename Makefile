BIN ?= ./zig-out/bin/rotate

build: fmt
	@zig build 

run: fmt
	@zig build run

fast: fmt
	@zig build -Drelease-fast=true run

test: fmt
	@zig build test

fmt:
	@zig fmt .

format: fmt

clean:
	@rm -rf ./zig-out/ ./zig-cache/
