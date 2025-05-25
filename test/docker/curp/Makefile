DOCKERFILE=Dockerfile
TAG_AMD64=test-curp-verifier-amd64
TAG_ARM64=test-curp-verifier-arm64

NO_CACHE_FLAG := $(if $(NO_CACHE),--no-cache,)

.PHONY: all amd64 arm64 test-local

all: amd64 arm64

amd64:
	docker buildx build --platform linux/amd64 -f $(DOCKERFILE) -t $(TAG_AMD64) $(NO_CACHE_FLAG) --load .
	docker run --rm $(TAG_AMD64)

arm64:
	docker buildx build --platform linux/arm64 -f $(DOCKERFILE) -t $(TAG_ARM64) $(NO_CACHE_FLAG) --load .
	docker run --rm $(TAG_ARM64)

test-local:
	gcc test_local.c \
		-I../../../src/rust/curp_generator/include \
		-I../../../src/rust/curp_verifier/include \
		-L../../../src/rust/curp_generator/target/release \
		-L../../../src/rust/curp_verifier/target/release \
		-lcurp_generator \
		-lcurp_verifier \
		-o test_curp

	DYLD_LIBRARY_PATH=../../../src/rust/curp_generator/target/release:../../../src/rust/curp_verifier/target/release ./test_curp
