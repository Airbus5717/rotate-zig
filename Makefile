run: fmt
	@zig build run

build: fmt
	@zig build

test: fmt
	@zig build test

fmt:
	@zig fmt .

clean:
	@rm -rf ./zig-out/ ./zig-cache/

delete: clean
	@rm -rf build.zig ./src/

create:
	@zig init-exe
