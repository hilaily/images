FROM debian:bullseye

# install node 
# wget -O _data/install_node.sh https://deb.nodesource.com/setup_23.x
COPY _data/install_node.sh ./install_node.sh

RUN bash install_node.sh && \
apt-get install -y --no-install-recommends nodejs && \
apt-get clean && \
apt-get autoclean && \
rm -rf /var/lib/apt/lists/* && \
npm config set registry https://registry.npmmirror.com && \
npm config set @buf:registry https://buf.build/gen/npm/v1 && \
npm install -g ts-protoc-gen && \
npm install -g @connectrpc/protoc-gen-connect-es@"^1.0.0" @bufbuild/protoc-gen-es@"^1.0.0" && \
npm install -g @connectrpc/connect@"^1.0.0" @connectrpc/connect-web@"^1.0.0" @bufbuild/protobuf@"^1.0.0"  && \
npm cache clean --force

# install go 1.23
# wget -O _data/go.tar.gz https://go.dev/dl/go1.23.3.linux-amd64.tar.gz
COPY _data/go.tar.gz /tmp/go.tar.gz

ENV GOPROXY=goproxy.cn,direct
ENV GOSUMDB=sum.golang.google.cn
ENV PATH=$PATH:/root/go/bin

RUN cd /tmp/ && \
tar zxf go.tar.gz && \
mv go /usr/local/ && \
ln -s /usr/local/go/bin/go /usr/local/bin/go && \
rm /tmp/go.tar.gz && \
go install github.com/bufbuild/buf/cmd/buf@v1.46.0 && \
go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.35.1 && \
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@v1.9.1 && \
go install connectrpc.com/connect/cmd/protoc-gen-connect-go@v1.17.0 && \
rm -rf /go/pkg /go/src 

# 设置工作目录
WORKDIR /app

