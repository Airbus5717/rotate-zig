run: fmt
	@zig build run

build: fmt
	@zig build

fmt:
	@zig fmt .

clean:
	@rm -rf zig-cache/ zig-out/
