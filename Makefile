build:
	@cargo build --release
ifeq ($(OS),Windows_NT)
	@copy target\release\tokenizers.lib libtokenizers.lib
else
	@cp target/release/libtokenizers.a .
endif
	@go build .

build-windows:
	@cargo build --release --target x86_64-pc-windows-msvc
	@mkdir -p target/release
	@cp target/x86_64-pc-windows-msvc/release/tokenizers.lib target/release/libtokenizers.lib
	@go build .

build-example:
	@docker build -f ./example/Dockerfile . -t tokenizers-example

release-darwin-%: test
	cargo build --release --target $*-apple-darwin
	mkdir -p artifacts/darwin-$*
	cp target/$*-apple-darwin/release/libtokenizers.a artifacts/darwin-$*/libtokenizers.a
	cd artifacts/darwin-$* && \
		tar -czf libtokenizers.darwin-$*.tar.gz libtokenizers.a
	mkdir -p artifacts/all
	cp artifacts/darwin-$*/libtokenizers.darwin-$*.tar.gz artifacts/all/libtokenizers.darwin-$*.tar.gz

release-linux-%: test
	docker buildx build --platform linux/$* --build-arg="DOCKER_TARGETPLATFORM=linux/$*" -f release/Dockerfile . -t tokenizers.linux-$*
	mkdir -p artifacts/linux-$*
	docker run -v $(PWD)/artifacts/linux-$*:/mnt --entrypoint ls tokenizers.linux-$* /workspace/tokenizers/lib/linux
	docker run -v $(PWD)/artifacts/linux-$*:/mnt --entrypoint cp tokenizers.linux-$* /workspace/tokenizers/lib/linux/$*/libtokenizers.a /mnt/libtokenizers.a
	cd artifacts/linux-$* && \
		tar -czf libtokenizers.linux-$*.tar.gz libtokenizers.a
	mkdir -p artifacts/all
	cp artifacts/linux-$*/libtokenizers.linux-$*.tar.gz artifacts/all/libtokenizers.linux-$*.tar.gz

release-windows-%: test
	cargo build --release --target $*-pc-windows-msvc
	mkdir -p artifacts/windows-$*
	cp target/$*-pc-windows-msvc/release/tokenizers.lib artifacts/windows-$*/libtokenizers.lib
	cd artifacts/windows-$* && \
		tar -czf libtokenizers.windows-$*.tar.gz libtokenizers.lib
	mkdir -p artifacts/all
	cp artifacts/windows-$*/libtokenizers.windows-$*.tar.gz artifacts/all/libtokenizers.windows-$*.tar.gz

release: release-darwin-aarch64 release-darwin-x86_64 release-linux-arm64 release-linux-x86_64 release-windows-x86_64 release-windows-aarch64
	cp artifacts/all/libtokenizers.darwin-aarch64.tar.gz artifacts/all/libtokenizers.darwin-arm64.tar.gz
	cp artifacts/all/libtokenizers.linux-arm64.tar.gz artifacts/all/libtokenizers.linux-aarch64.tar.gz
	cp artifacts/all/libtokenizers.linux-x86_64.tar.gz artifacts/all/libtokenizers.linux-amd64.tar.gz
	cp artifacts/all/libtokenizers.windows-x86_64.tar.gz artifacts/all/libtokenizers.windows-amd64.tar.gz
	cp artifacts/all/libtokenizers.windows-aarch64.tar.gz artifacts/all/libtokenizers.windows-arm64.tar.gz

test: build
	@go test -ldflags="-extldflags '-L./'" -v ./... -count=1

clean:
ifeq ($(OS),Windows_NT)
	@if exist libtokenizers.lib del libtokenizers.lib
	@if exist libtokenizers.a del libtokenizers.a
	@if exist target rmdir /s /q target
else
	rm -rf libtokenizers.a libtokenizers.lib target
endif

bazel-sync:
	CARGO_BAZEL_REPIN=1 bazel sync --only=crate_index
