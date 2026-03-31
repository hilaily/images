mkdir -p _data
cd _data
wget -O install_node.sh https://deb.nodesource.com/setup_20.x
cd ..

# Go tarball is now downloaded at build time based on TARGETARCH,
# no need to pre-download it.

# Multi-platform build (amd64 + arm64):
# docker buildx build --platform linux/amd64,linux/arm64 -t <image_name> .
#
# Single-platform build:
# docker buildx build --platform linux/amd64 -t <image_name> .
# docker buildx build --platform linux/arm64 -t <image_name> .
