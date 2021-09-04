run: fmt
	@zig build run

fast: fmt
	@zig build -Drelease-fast=true run

build: fmt
	@zig build

test: fmt
	@zig build test

fmt:
	@zig fmt .

clean:
	@rm -rf ./zig-out/ ./zig-cache/
