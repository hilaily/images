# 首先选择一个带有 Go 的基础镜像
FROM golang:1.23.2-bullseye

# 设置工作目录
WORKDIR /app

# 安装 protobuf 和 gRPC
#RUN apt-get update && apt-get install -y protobuf-compiler

RUN	go install github.com/bufbuild/buf/cmd/buf@latest

ENV GOPROXY goproxy.cn,direct
ENV GOSUMDB sum.golang.google.cn

RUN	go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
RUN	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
RUN	go install connectrpc.com/connect/cmd/protoc-gen-connect-go@latest

# 安装 Node.js 和 npm
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y nodejs

RUN npm config set registry https://registry.npmmirror.com
RUN npm config set @buf:registry https://buf.build/gen/npm/v1
RUN npm install -g ts-protoc-gen
	#npm install -g @bufbuild/buf @connectrpc/protoc-gen-connect-es@"^1.0.0" @bufbuild/protoc-gen-es@"^1.0.0"
RUN npm install -g @connectrpc/protoc-gen-connect-es@"^1.0.0" @bufbuild/protoc-gen-es@"^1.0.0"
RUN npm install -g @connectrpc/connect@"^1.0.0" @connectrpc/connect-web@"^1.0.0" @bufbuild/protobuf@"^1.0.0"
