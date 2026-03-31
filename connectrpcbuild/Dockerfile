# syntax=docker/dockerfile:1
# 需要 BuildKit（DOCKER_BUILDKIT=1，Docker 24+ 通常默认开启）
FROM debian:bullseye

# install node 
# wget -O _data/install_node.sh https://deb.nodesource.com/setup_23.x
COPY ./install_node.sh ./install_node.sh

RUN bash install_node.sh && \
apt-get install -y --no-install-recommends nodejs wget && \
apt-get clean && \
apt-get autoclean && \
rm -rf /var/lib/apt/lists/* && \
npm config set registry https://registry.npmmirror.com && \
npm config set @buf:registry https://buf.build/gen/npm/v1 && \
npm install -g ts-protoc-gen && \
npm install -g @connectrpc/protoc-gen-connect-es@"^1.0.0" @bufbuild/protoc-gen-es@"^1.0.0" && \
npm install -g @connectrpc/connect@"^1.0.0" @connectrpc/connect-web@"^1.0.0" @bufbuild/protobuf@"^1.0.0"  && \
npm cache clean --force

# install go 1.23 (multi-arch: amd64/arm64)
# 使用 BuildKit 缓存目录复用已下载的 go*.tar.gz；用 gzip -t 校验完整性，避免残缺缓存被复用
ARG TARGETARCH
ENV GO_VERSION=1.23.3
ENV GOPROXY=goproxy.cn,direct
ENV GOSUMDB=sum.golang.google.cn
ENV PATH=$PATH:/root/go/bin

RUN --mount=type=cache,target=/var/cache/go-downloads,sharing=locked \
    GO_TAR="go${GO_VERSION}.linux-${TARGETARCH}.tar.gz" && \
    CACHE_FILE="/var/cache/go-downloads/${GO_TAR}" && \
    if [ ! -s "${CACHE_FILE}" ] || ! gzip -t "${CACHE_FILE}" 2>/dev/null; then \
      rm -f "${CACHE_FILE}" && \
      wget -q -O "${CACHE_FILE}" "https://go.dev/dl/${GO_TAR}" && \
      gzip -t "${CACHE_FILE}"; \
    fi && \
    cp "${CACHE_FILE}" /tmp/go.tar.gz && \
    cd /tmp/ && \
    tar zxf go.tar.gz && \
    mv go /usr/local/ && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    rm /tmp/go.tar.gz && \
    go install github.com/bufbuild/buf/cmd/buf@v1.46.0 && \
    go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.35.1 && \
    go install github.com/fullstorydev/grpcurl/cmd/grpcurl@v1.9.1 && \
    go install connectrpc.com/connect/cmd/protoc-gen-connect-go@v1.17.0 && \
    go install github.com/sudorandom/protoc-gen-connect-openapi/cmd/protoc-gen-connect-openapi@latest && \
    rm -rf /go/pkg /go/src 

# 设置工作目录
WORKDIR /app

