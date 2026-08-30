# Ou-Mieru（For Nobrand Dual）

<p align="center">
  <img src="assets/ou-mieru-logo.jpg" width="320" alt="Ou-Mieru 标志">
</p>

<p align="center">
  <strong>为 NobrandCloud 的 Dual 机器设计，为懒哥们和图省事的爹们提供的 Mieru 协议搭建脚本。</strong>
</p>

<p align="center">作者：<a href="https://www.nodeseek.com/space/38057#/general">nodeseek@cshaizhihao</a></p>

Ou-Mieru 面向“大陆入口 + 日本落地”的 Nobrand Dual VPS，在日本 VPS 上安装 Mieru，并自动输出客户端所需的协议配置。

## 🚀 快速开始

在日本 VPS 上执行一行命令：

```bash
curl -fsSL https://raw.githubusercontent.com/cshaizhihao/Ou-Mieru/main/nobrand -o nobrand && chmod +x nobrand && sudo ./nobrand
```

选择 `1) 安装Mieru协议`，脚本会先显示自动识别到的网卡和 IP，然后按步骤引导填写 Nobrand 控制台“详情”区域中的信息。安装完成后可直接使用：

```bash
sudo nobrand
```

## 🧭 交互式填写

脚本会自动识别：

- 日本 VPS 公网 IPv4
- 默认网卡和其他 IPv4 网卡
- 本机已占用的端口

请从 Nobrand 控制台 VPS 的“详情”区域填写：

| 步骤 | 对应字段 | 填写方式 |
| --- | --- | --- |
| 第 1 步 | `专线网卡 · 可用端口范围` | 选择一个未占用端口，作为 VPS 上 Mieru 的监听端口。不要使用 SSH 端口。 |
| 第 2 步 | `专线网卡 · 移动入口 (China Mobile)` | 原样复制移动入口 IP。 |
| 第 3 步 | 入口端口 | 这是移动入口 IP 对外提供的端口。无特殊需求时直接回车，使用第 1 步的端口。 |
| 最后 | 节点名称 | 可直接回车使用默认名称 `ou-mieru`。 |

简单理解：`--port` 是日本 VPS 本机监听端口，入口端口是客户端连接移动入口 IP 时使用的端口。只有服务商明确提供了不同的端口映射时，两者才需要填写不同值。

## ✨ 功能

- 安装 Mieru 协议：TCP + IPLC 预设，适用于 Nobrand Dual 网络。
- 自动生成用户名和密码，并输出 `mieru://` 协议链接。
- 输出通用 YAML 配置，便于导入支持 Mieru 的客户端。
- 查看当前协议、服务状态和诊断结果。
- 已有 Mieru 时支持确认后重装。
- 一键卸载 Mieru 及 Ou-Mieru 管理文件。

## 🛠️ 菜单与命令

```text
1) 安装Mieru协议
2) 查看 Mieru 协议
3) 一键卸载
0) 退出
```

安装完成后：

```bash
sudo nobrand show
sudo nobrand uninstall
sudo nobrand uninstall --yes
```

如果服务器已经安装过 Mieru，重新安装时可在命令行加入 `--reinstall`：

```bash
sudo ./nobrand install --port 20101 --entry-host 211.136.162.188 --reinstall
```

交互式安装会先询问是否卸载旧实例；确认后才会继续安装。

## ⚙️ 命令行参数

```bash
sudo ./nobrand install \
  --port 20101 \
  --entry-host 211.136.162.188 \
  --entry-port 20101 \
  --name nobrand-jp-01
```

| 参数 | 含义 |
| --- | --- |
| `--port` | 日本 VPS 上 Mieru 实际监听端口，必填。 |
| `--entry-host` | 客户端连接的移动入口 IP 或域名，必填。 |
| `--entry-port` | 客户端连接的入口端口；不填时使用 `--port`。 |
| `--name` | 节点名称。 |
| `--user` / `--password` | 自定义 Mieru 凭据；默认随机生成。 |
| `--reinstall` | 已有 Mieru 时先卸载旧实例，再重新安装。 |
| `--dry-run` | 仅检查参数和环境，不修改系统。 |

## 🔍 常用检查

```bash
sudo nobrand show
install-mita status
install-mita doctor
ss -lntp | grep ':20101'
```

服务商侧的入口放行和 L4 转发由 Nobrand 控制台负责，Ou-Mieru 只配置 VPS 本身。

## 🔐 注意事项

- 协议链接包含用户名和密码，请勿公开截图或提交到 Git。
- SSH 私钥曾经公开过时，应立即在服务商控制台轮换。
- 请在法律法规和服务商使用政策允许的范围内使用。

## 🙏 致谢

- [ike-sh/mieru-OneClick](https://github.com/ike-sh/mieru-OneClick)：Mieru 服务端安装器。
- [enfein/mieru](https://github.com/enfein/mieru)：Mieru 协议与客户端实现。

## 📄 许可证

[MIT](LICENSE)
