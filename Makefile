run:
	@zig build run

build:
	@zig build

fmt:
	@zig fmt .

clean:
	@rm -rf zig-cache/ zig-out/
