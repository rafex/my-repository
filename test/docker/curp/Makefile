DOCKERFILE=Dockerfile
TAG_AMD64=test-curp-verifier-amd64
TAG_ARM64=test-curp-verifier-arm64

.PHONY: all amd64 arm64

all: amd64 arm64

amd64:
	docker buildx build --platform linux/amd64 -f $(DOCKERFILE) -t $(TAG_AMD64) --load .
	docker run --rm $(TAG_AMD64)

arm64:
	docker buildx build --platform linux/arm64 -f $(DOCKERFILE) -t $(TAG_ARM64) --load .
	docker run --rm $(TAG_ARM64)
