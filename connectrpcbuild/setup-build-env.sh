#!/usr/bin/env bash
# 构建前环境准备：在 Mac / Linux 上根据「Docker 实际运行架构」与「目标平台」判断是否需要 QEMU/binfmt。
# 用法：
#   ./setup-build-env.sh                    # 默认检查 linux/amd64,linux/arm64
#   ./setup-build-env.sh linux/arm64
#   PLATFORMS=linux/arm64 ./setup-build-env.sh
set -euo pipefail

log() { printf '%s\n' "[setup-build-env] $*"; }
warn() { printf '%s\n' "[setup-build-env] 警告: $*" >&2; }

usage() {
  cat <<'EOF'
用法:
  ./setup-build-env.sh [平台 ...]
  PLATFORMS=linux/arm64 ./setup-build-env.sh

默认检查平台: linux/amd64,linux/arm64（与 Makefile 中 PLATFORMS 一致时可省略参数）

示例:
  ./setup-build-env.sh linux/arm64
  ./setup-build-env.sh linux/amd64,linux/arm64
  ./setup-build-env.sh linux/amd64 linux/arm64
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if ! docker info >/dev/null 2>&1; then
  echo "错误: 无法访问 Docker（未启动或无权限）。" >&2
  exit 1
fi

# Docker 守护进程所在 Linux 的架构（在 Mac 上为虚拟机架构，比本机 uname 可靠）
docker_server_arch_raw="$(docker info -f '{{.Architecture}}' 2>/dev/null || true)"
if [[ -z "${docker_server_arch_raw}" ]]; then
  docker_server_arch_raw="$(docker version -f '{{.Server.Arch}}' 2>/dev/null || true)"
fi
if [[ -z "${docker_server_arch_raw}" ]]; then
  docker_server_arch_raw="$(docker info 2>/dev/null | awk -F': ' '/Architecture:/{print $2; exit}')"
fi

normalize_docker_arch() {
  case "$1" in
    x86_64|amd64) echo amd64 ;;
    aarch64|arm64) echo arm64 ;;
    *) echo "" ;;
  esac
}

DOCKER_ARCH="$(normalize_docker_arch "${docker_server_arch_raw}")"
if [[ -z "${DOCKER_ARCH}" ]]; then
  warn "无法从 docker info 解析架构，尝试用默认平台容器探测..."
  um="$(docker run --rm alpine:3.19 uname -m 2>/dev/null || true)"
  DOCKER_ARCH="$(normalize_docker_arch "${um}")"
fi
if [[ -z "${DOCKER_ARCH}" ]]; then
  warn "仍无法确定 Docker 引擎架构，将无法判断是否需要 binfmt；若构建报 exec format error，请手动执行: docker run --privileged --rm tonistiigi/binfmt --install all"
fi

# 解析目标平台列表
if [[ "$#" -gt 0 ]]; then
  # 支持: ./setup-build-env.sh linux/arm64 linux/amd64
  # 或单行: ./setup-build-env.sh linux/amd64,linux/arm64
  PLATFORMS_JOINED="$*"
  PLATFORMS_JOINED="${PLATFORMS_JOINED// /,}"
elif [[ -n "${PLATFORMS:-}" ]]; then
  PLATFORMS_JOINED="${PLATFORMS}"
else
  PLATFORMS_JOINED="linux/amd64,linux/arm64"
fi

IFS=',' read -r -a PLAT_ARRAY <<< "${PLATFORMS_JOINED}"

extract_target_arch() {
  case "$1" in
    linux/arm64|linux/aarch64) echo arm64 ;;
    linux/amd64|linux/x86_64) echo amd64 ;;
    arm64) echo arm64 ;;
    amd64) echo amd64 ;;
    *) echo "" ;;
  esac
}

need_binfmt=0
for raw in "${PLAT_ARRAY[@]}"; do
  p="${raw// /}"
  [[ -z "$p" ]] && continue
  targ="$(extract_target_arch "$p")"
  if [[ -z "$targ" ]]; then
    warn "无法识别平台: '$p'，已跳过。"
    continue
  fi
  if [[ -n "${DOCKER_ARCH}" && "${DOCKER_ARCH}" != "${targ}" ]]; then
    need_binfmt=1
    log "跨架构构建: Docker 引擎架构=${DOCKER_ARCH}，目标=${targ}（${p}）"
  fi
done

if [[ "$need_binfmt" -eq 0 ]]; then
  if [[ -n "${DOCKER_ARCH}" ]]; then
    log "无需 QEMU/binfmt：Docker 引擎架构 (${DOCKER_ARCH}) 与目标平台一致，或仅构建本机对应架构。"
  else
    log "未检测到跨架构组合，跳过 binfmt。"
  fi
  exit 0
fi

log "正在注册 binfmt / QEMU（docker run --privileged ... tonistiigi/binfmt）..."
if docker run --privileged --rm tonistiigi/binfmt --install all; then
  log "binfmt 配置完成。"
else
  echo "错误: binfmt 安装失败（无特权、策略禁止 --privileged 或网络问题）。" >&2
  exit 1
fi
