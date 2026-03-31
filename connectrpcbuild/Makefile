IMAGE_NAME ?= connectrpcbuild
BUILD_CONTEXT ?= .
PLATFORMS ?= linux/amd64,linux/arm64

# BuildKit：启用 Dockerfile 里 Go 下载的 cache mount 复用
export DOCKER_BUILDKIT=1

.PHONY: help build build-amd64 build-arm64 build-multi prune-buildx-cache

help:
	@echo "Usage:"
	@echo "  make build IMAGE_NAME=<image_name>          # default: amd64"
	@echo "  make build-amd64 IMAGE_NAME=<image_name>"
	@echo "  make build-arm64 IMAGE_NAME=<image_name>"
	@echo "  make build-multi IMAGE_NAME=<image_name>"
	@echo ""
	@echo "Go 安装包会缓存在 BuildKit 中，多次构建通常不会重复下载。"
	@echo "  make prune-buildx-cache   # 清理 buildx 缓存（含上述缓存）"

build: build-amd64

build-amd64:
	docker buildx build --platform linux/amd64 -t $(IMAGE_NAME) $(BUILD_CONTEXT)

build-arm64:
	docker buildx build --platform linux/arm64 -t $(IMAGE_NAME) $(BUILD_CONTEXT)

build-multi:
	docker buildx build --platform $(PLATFORMS) -t $(IMAGE_NAME) $(BUILD_CONTEXT)

prune-buildx-cache:
	docker buildx prune -f
