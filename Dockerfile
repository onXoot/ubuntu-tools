# syntax=docker/dockerfile:1.7

# 时区数据阶段：alpine 基础镜像不含 tzdata，需先安装
FROM alpine:3.24.1 AS tzdata
RUN apk add --no-cache tzdata

FROM ubuntu:26.04

# 合并 apt 操作为单层：消除重复 apt-get update；cache mount 跨构建复用 deb 下载，且 apt 缓存不落入镜像
# 先用默认源装 ca-certificates，否则 HTTPS 镜像源无法验证证书
RUN --mount=type=cache,target=/var/cache/apt \
    --mount=type=cache,target=/var/lib/apt/lists \
    apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates \
    && sed -i \
        -e 's|http://archive.ubuntu.com/ubuntu/|https://mirrors.tuna.tsinghua.edu.cn/ubuntu/|g' \
        -e 's|http://security.ubuntu.com/ubuntu/|https://mirrors.tuna.tsinghua.edu.cn/ubuntu/|g' \
        /etc/apt/sources.list.d/ubuntu.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        wget curl jq file \
        iputils-ping \
        iproute2 \
        procps \
        lsof \
        python3 \
    && ln -s /usr/bin/python3 /usr/bin/python

# 时区设置必须放在 apt 之后：apt 安装 tzdata（python3 依赖）时，其 postinst 会把 /etc/localtime
# 重置为 Etc/UTC 并删除 /etc/timezone，会覆盖前面层写入的时区配置
COPY --from=tzdata /usr/share/zoneinfo/Asia/Shanghai /usr/share/zoneinfo/Asia/Shanghai
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone
ENV TZ=Asia/Shanghai

# install uv（固定版本，latest 变动会导致该层缓存失效）
COPY --from=ghcr.io/astral-sh/uv:0.12.3 /uv /uvx /usr/bin/
# config python env
ENV UV_CACHE_DIR=/root/cache/uv \
    UV_INDEX_URL=https://pypi.tuna.tsinghua.edu.cn/simple \
    PIP_CACHE_DIR=/root/cache/pip


COPY node-v24.19.0-linux-x64 /opt/node/
ENV NODE_HOME=/opt/node
ENV PATH=$NODE_HOME/bin:$PATH

# 安装claude code  2.1.228 
RUN npm i -g @anthropic-ai/claude-agent-sdk@0.3.228 \
	&& mv /opt/node/lib/node_modules/\@anthropic-ai/claude-agent-sdk/node_modules/\@anthropic-ai/claude-agent-sdk-linux-x64/claude /usr/bin/ \
	&& npm uninstall -g @anthropic-ai/claude-agent-sdk@0.3.228 \
	&& rm -rf /opt/node/lib/node_modules/\@anthropic-ai/ 


# 保持容器存活，进入容器用 kubectl exec / docker exec 起 bash
ENTRYPOINT ["sleep", "infinity"]
