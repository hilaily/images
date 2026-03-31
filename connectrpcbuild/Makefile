IMAGE_NAME ?= laily/connectrpcbuild
BUILD_CONTEXT ?= .
PLATFORMS ?= linux/amd64,linux/arm64
VERSION ?=

# BuildKit：启用 Dockerfile 里 Go 下载的 cache mount 复用
export DOCKER_BUILDKIT=1

.PHONY: help prep build build-amd64 build-arm64 build-multi release release-latest check-version prune-buildx-cache show-arch

help:
	@echo "Usage:"
	@echo "  make build IMAGE_NAME=<image_name>          # default: amd64"
	@echo "  make build-amd64 IMAGE_NAME=<image_name>"
	@echo "  make build-arm64 IMAGE_NAME=<image_name>"
	@echo "  make build-multi IMAGE_NAME=<image_name>"
	@echo "  make release IMAGE_NAME=<repo/image> VERSION=<x.y.z>   # 多架构构建并推送"
	@echo "  make release-latest IMAGE_NAME=<repo/image> VERSION=<x.y.z>   # 额外推 latest"
	@echo "  make prep PLATFORMS=linux/arm64               # 仅准备环境（QEMU/binfmt）"
	@echo ""
	@echo "构建前会自动运行 setup-build-env.sh：按 Docker 引擎架构与目标平台判断是否需要 binfmt（Mac / Linux 通用）。"
	@echo "  bash setup-build-env.sh --help"
	@echo ""
	@echo "Go 安装包会缓存在 BuildKit 中，多次构建通常不会重复下载。"
	@echo "  make prune-buildx-cache   # 清理 buildx 缓存（含上述缓存）"

prep:
	bash setup-build-env.sh "$(PLATFORMS)"

show-arch:
	@echo "uname: $$(uname -m)"
	@docker info -f 'Docker Architecture: {{.Architecture}}' 2>/dev/null || true

build: build-amd64

build-amd64: prep-amd64
	docker buildx build --platform linux/amd64 -t $(IMAGE_NAME) $(BUILD_CONTEXT)

build-arm64: prep-arm64
	docker buildx build --platform linux/arm64 -t $(IMAGE_NAME) $(BUILD_CONTEXT)

build-multi: prep-multi
	docker buildx build --platform $(PLATFORMS) -t $(IMAGE_NAME) $(BUILD_CONTEXT)

check-version:
	@if [ -z "$(VERSION)" ]; then \
		echo "错误: 请指定 VERSION，例如: make release IMAGE_NAME=<repo/image> VERSION=v1.2.3"; \
		exit 1; \
	fi

release: prep-multi check-version
	docker buildx build --platform $(PLATFORMS) \
		-t $(IMAGE_NAME):$(VERSION) \
		$(BUILD_CONTEXT) --push

release-latest: prep-multi check-version
	docker buildx build --platform $(PLATFORMS) \
		-t $(IMAGE_NAME):$(VERSION) \
		-t $(IMAGE_NAME):latest \
		$(BUILD_CONTEXT) --push

prep-amd64:
	bash setup-build-env.sh linux/amd64

prep-arm64:
	bash setup-build-env.sh linux/arm64

prep-multi:
	bash setup-build-env.sh "$(PLATFORMS)"

prune-buildx-cache:
	docker buildx prune -f
