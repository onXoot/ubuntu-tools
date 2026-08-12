# ubuntu-tools

基于 `ubuntu:26.04` 的常用工具镜像，内置 Python 3、Node.js、uv 包管理器、Claude Code、Codex，默认时区 `Asia/Shanghai`。

## 镜像

镜像托管在 GitHub Container Registry（GHCR）：

**`ghcr.io/onxoot/ubuntu-tools`**（[镜像页面](https://github.com/users/onxoot/packages/container/package/ubuntu-tools)）

- 源码仓库：<https://github.com/onXoot/ubuntu-tools>

## 使用

```bash
# 拉取并运行（容器默认保持存活，进入后用 exec 起 bash）
docker run -d --name ubuntu-tools ghcr.io/onxoot/ubuntu-tools:latest
docker exec -it ubuntu-tools bash

# 或直接执行命令
docker run --rm --entrypoint sh ghcr.io/onxoot/ubuntu-tools:latest -c 'date'
```

## 内置内容

| 组件 | 说明 |
|---|---|
| 时区 | `Asia/Shanghai`（`TZ` 环境变量 + `/etc/localtime` + `/etc/timezone`） |
| apt 源 | 清华 TUNA 镜像源 |
| Python 3 | `/usr/bin/python3`，并软链为 `/usr/bin/python` |
| uv | Python 包管理器（`uv` / `uvx`），pypi 源为清华 TUNA |
| Node.js | v24.19.0，位于 `/opt/node`，`NODE_HOME=/opt/node` |
| Claude Code | v2.1.228，位于 `/usr/bin/claude` |
| Codex | v0.147.0（OpenAI），位于 `/usr/bin/codex` |
| 常用工具 | `wget` `curl` `jq` `file` `iputils-ping` `iproute2` `procps` `lsof` |

## 构建

```bash
# 需要 node-v24.19.0-linux-x64 目录位于构建上下文（从官网下载解压）
docker build -t ubuntu-tools:latest .
```

## 环境变量

| 变量 | 值 |
|---|---|
| `TZ` | `Asia/Shanghai` |
| `NODE_HOME` | `/opt/node` |
| `UV_CACHE_DIR` | `/root/cache/uv` |
| `UV_INDEX_URL` | `https://pypi.tuna.tsinghua.edu.cn/simple` |
| `PIP_CACHE_DIR` | `/root/cache/pip` |

## 发布到 GHCR

```bash
echo $TOKEN | docker login ghcr.io -u <用户名> --password-stdin
docker tag ubuntu-tools:latest ghcr.io/onxoot/ubuntu-tools:latest
docker push ghcr.io/onxoot/ubuntu-tools:latest
```

> token 需要 `write:packages` 权限（classic PAT 勾选 `write:packages`、`read:packages`）。
