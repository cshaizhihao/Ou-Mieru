# Ou-Mieru (For Nobrand Dual)

<p align="center">
  <img src="assets/ou-mieru-logo.jpg" width="320" alt="Ou-Mieru logo">
</p>

<p align="center">
  <strong>为 NobrandCloud 的 Dual 机器设计，面向懒人和小白的一键 Mieru 协议搭建脚本。</strong>
</p>

<p align="center">作者：<a href="https://www.nodeseek.com/space/23179">nodeseek@cshaizhihao</a></p>

Ou-Mieru 用于具有“大陆入口 + 日本落地”L4 转发网络的 Nobrand Dual VPS：在日本 VPS 部署 Mieru，客户端连接服务商提供的移动入口，再经专线到日本公网出口。

## 小白直接使用

```bash
curl -fLO https://raw.githubusercontent.com/cshaizhihao/Ou-Mieru/main/nobrand
chmod +x nobrand
sudo ./nobrand
```

选择菜单 `1` 后，脚本会逐步提示你从 Nobrand 控制台 VPS“详情”区域复制哪一项，不需要自己猜网络拓扑。安装完成后会自动创建全局快捷命令：

```bash
sudo nobrand
```

## 脚本能自动获取什么？

脚本在 VPS 内可以自动识别：

- 日本 VPS 的公网 IPv4 和默认网卡。
- 专线网卡等其他本地 IPv4 网卡。
- 当前已被系统占用的端口。

但以下信息存在于服务商的 L4/运营商网络，**不会下发给 VPS**，因此不能凭空自动获取：

- 面板中的“专线网卡 - 移动入口 (China Mobile)”IP。
- 面板中的“专线网卡 - 可用端口范围”。
- 服务商侧是否已为该端口建立入口到 VPS 的转发。

这也是交互式安装仍要求用户从面板填写两项信息的原因。脚本会明确显示字段名称和填写顺序。

## 需要从面板填写的字段

进入 Nobrand 控制台，打开 VPS 的“详情”区域：

| 面板字段 | 在脚本中如何填写 |
| --- | --- |
| `专线网卡 - 可用端口范围` | 从范围中选择一个端口，填入第 1 步“Mieru 端口”。不要占用 SSH 端口。 |
| `专线网卡 - 移动入口 (China Mobile)` | 原样复制 IP，填入第 2 步“移动入口 IP”。 |
| `专线网卡 - SSH端口` | 仅用于服务商可能提供的 SSH 管理，不要作为 Mieru 端口。 |
| `日本网卡 IP` / `IPv4 地址` | 仅供核对，脚本会自动从系统检测。 |
| `专线网卡 - 内网 IP` | 仅供核对，正常不需要手动填写。 |

典型网络结构：

```text
客户端
  -> 服务商移动入口 IP:端口
  -> 服务商沪日 / IPLC L4 转发
  -> 日本 Dual VPS 的 Mieru TCP 端口
  -> 日本公网出口
```

> [!IMPORTANT]
> 服务商的 L4 转发和端口放行由服务商面板负责。Ou-Mieru 只配置 VPS 本身，不能替你创建运营商侧的端口映射。

## 功能

- **安装Mieru协议**：TCP + IPLC 预设，MTU 1400、关闭多路复用、No-Wait 握手。
- **输出通用配置**：打印标准 `mieru://` URI 和 Clash/mihomo YAML。
- **网络调优**：启用内核实际提供的 BBR、即时应用 `fq`，TCP 自动缓冲最高 64MiB。
- **查看协议**：执行 `nobrand show` 或菜单第二项，重新显示 URI、YAML 和服务状态。
- **一键卸载**：执行 `nobrand uninstall`，卸载 Mieru 并清理 Ou-Mieru 的管理文件。
- **安全默认值**：固定、SHA-256 校验上游安装器版本；自动生成独立用户名与密码；不改 SSH、路由、DNS 或防火墙。

## 菜单与命令

```text
1) 安装Mieru协议
2) 查看 Mieru 协议
3) 一键卸载
0) 退出
```

安装后：

```bash
sudo nobrand show
sudo nobrand uninstall
sudo nobrand uninstall --yes
```

不使用菜单时也可直接提供参数：

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
| `--entry-host` | 客户端连接的服务商移动入口 IP 或域名，必填。 |
| `--entry-port` | 客户端连接的入口端口；不填时和 `--port` 相同。 |
| `--name` | 节点名称。 |
| `--user` / `--password` | 自定义 Mieru 凭据；默认随机生成。 |
| `--reinstall` | 已有 Mieru 时先卸载旧实例，再重新安装。 |
| `--dry-run` | 校验参数与本机环境，不执行写入。 |

入口端口是服务商移动入口 IP 对外提供的端口；`--port` 是日本 VPS 上 Mieru 实际监听的端口。多数 Nobrand Dual 端口映射是一一对应的，入口端口和本机端口相同，**无特殊需求时第 3 步直接回车即可**。只有服务商明确给出不同的外部端口时，才填写第 3 步的入口端口。

## 关于 BBRv3、FQ 与 64MiB 缓冲

Nobrand Dual 常见的 Debian 13 内核提供的是标准 `bbr`，而不是名为 `bbr3` 的独立模块。Ou-Mieru 不会下载或伪装第三方 BBRv3 内核：它会检测当前内核，只有实际存在 `bbr` 时才启用。

脚本写入 `/etc/sysctl.d/99-ou-mieru-tuning.conf`：

- `net.core.default_qdisc=fq`，并即时把有 IPv4 地址的接口切换到 `fq`。
- 接收和发送 TCP 自动缓冲上限为 64MiB，初始缓冲仍保持很小，不会为每条连接预留 64MiB。
- 开启 TCP 窗口缩放、自动接收缓冲，调整 backlog，并禁用空闲连接后的慢启动。

速度还受大陆入口、跨境专线、白名单省份、运营商和目标站点影响。系统参数只能消除 VPS 端限制，无法突破服务商端带宽或线路质量。

## 常用检查

```bash
sudo nobrand show
install-mita status
install-mita doctor
ss -lntp | grep ':20101'
tc qdisc show dev eth0
sysctl net.ipv4.tcp_congestion_control net.core.default_qdisc
```

`install-mita doctor` 只验证 VPS 内的服务和配置。最终仍应从你的目标省份网络测试服务商入口是否可达。

## 卸载说明

`nobrand uninstall` 会调用上游 Mieru OneClick 的卸载功能，并移除 Ou-Mieru 的快捷命令、节点元数据和 TCP 调优文件。为避免意外，中途会要求确认；自动化使用 `--yes`。

当前已应用的 `fq` qdisc 会维持到下次重启或网卡重建，这是 Linux 的运行时行为。卸载不会修改 SSH、路由、DNS 或服务商面板中的端口映射。

## 安全与免责声明

- 节点 URI 含用户名和密码。不要公开截图、终端日志或将其提交到 Git。
- 不要使用已经公开过的 SSH 私钥；发现泄露后应立即轮换密钥。
- 升级上游安装器前，请同时更新脚本中的版本与 SHA-256。
- 请仅在法律法规和服务商可接受使用政策允许的范围内使用。

## 致谢

- [ike-sh/mieru-OneClick](https://github.com/ike-sh/mieru-OneClick)：Mieru 服务端安装和管理。
- [enfein/mieru](https://github.com/enfein/mieru)：Mieru 协议与客户端实现。

## License

[MIT](LICENSE)
