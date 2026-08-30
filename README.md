# Ou-Mieru (For Nobrand Dual)

<p align="center">
  <img src="assets/ou-mieru-logo.jpg" width="320" alt="Ou-Mieru logo">
</p>

<p align="center">
  <strong>为 NobrandCloud 的 Dual 机器设计，面向懒人和小白的一键 Mieru 协议搭建脚本。</strong>
</p>

<p align="center">Author: <a href="https://www.nodeseek.com/space/23179">nodeseek@cshaizhihao</a></p>

Ou-Mieru 面向具有“大陆入口 + 日本落地”L4 转发网络的 Nobrand Dual VPS。它在日本 VPS 部署 Mieru，将客户端配置指向服务商提供的入口地址，并输出可导入妙妙屋X（MMWX）的 `mieru://` URI 与 Clash/mihomo YAML。

> [!IMPORTANT]
> 服务商的 L4 入口和端口映射由服务商面板负责。运行本脚本前，请先确认所选端口已在面板允许并转发到 VPS；脚本不会也无法替你创建运营商侧转发规则。

## 功能

- **一键安装 Mieru**：TCP + IPLC 预设，MTU 1400、关闭多路复用、No-Wait 握手。
- **妙妙屋X兼容**：输出 `mieru://`，而不是 Mieru 的 `mierus://` 简化分享链接。
- **网络调优**：启用内核实际提供的 BBR、即时应用 `fq`，TCP 自动缓冲最高 64MiB。
- **查看协议**：执行 `nobrand show` 或菜单第二项，重新显示节点 URI 与 YAML。
- **一键卸载**：执行 `nobrand uninstall`，卸载 Mieru 并清理 Ou-Mieru 的管理文件。
- **安全默认值**：固定、SHA-256 校验上游安装器版本；自动生成独立用户名与密码；不改 SSH、路由、DNS 或防火墙。

## 适用环境

- Debian 12/13 或 Ubuntu 的新 VPS，使用 `root` 或 `sudo`。
- NobrandCloud Dual 类机器，已有可用的中国移动/专线 L4 入口。
- 已从面板挑选一个可用端口，且不与 SSH 管理端口冲突。

典型网络结构：

```text
客户端
  -> 服务商大陆入口 IP:端口
  -> 服务商沪日 / IPLC L4 转发
  -> 日本 Dual VPS 的 Mieru TCP 端口
  -> 日本公网出口
```

## 安装

建议先下载后审阅，再运行。安装成功后会自动建立全局快捷命令 `nobrand`。

```bash
curl -fLO https://raw.githubusercontent.com/cshaizhihao/Ou-Mieru/main/nobrand
chmod +x nobrand
sudo ./nobrand install \
  --port 20101 \
  --entry-host 211.136.162.188 \
  --entry-port 20101 \
  --name nobrand-jp-01
```

参数说明：

| 参数 | 含义 |
| --- | --- |
| `--port` | 日本 VPS 上 Mieru 实际监听端口，必填。 |
| `--entry-host` | 客户端连接的服务商大陆入口 IP 或域名，必填。 |
| `--entry-port` | 客户端连接的入口端口；不填时和 `--port` 相同。 |
| `--name` | 妙妙屋X节点名称。 |
| `--user` / `--password` | 自定义 Mieru 凭据；默认随机生成。 |
| `--dry-run` | 校验参数与本机环境，不执行写入。 |

安装后也可直接运行菜单：

```bash
sudo nobrand
```

## 菜单与命令

```text
1) One-click install Mieru
2) View Mieru protocol
3) One-click uninstall
0) Exit
```

非交互模式：

```bash
sudo nobrand show
sudo nobrand uninstall
sudo nobrand uninstall --yes
```

## 导入妙妙屋X

安装完成后复制脚本输出的整个 `mieru://` URI，在妙妙屋X的节点导入页面直接粘贴即可。

不要把安装器原样输出的 `mierus://` 简化链接粘到妙妙屋X里。`mierus://` 是 Mieru 客户端的简化分享格式；本项目会输出妙妙屋X可解析的 `mieru://` 格式。

也可以导入脚本输出的 Clash/mihomo YAML。Mieru 官方说明了 mihomo 的 `type: mieru` 配置字段和客户端参数。[Mieru 客户端文档](https://github.com/enfein/mieru/blob/main/docs/client-install.zh_CN.md)

## 关于 BBRv3、FQ 与 64MiB 缓冲

Nobrand Dual 目前常见的 Debian 13 内核提供的是标准 `bbr`，而不是名为 `bbr3` 的独立模块。Ou-Mieru 不会下载或伪装第三方 BBRv3 内核：它会检测当前内核，只有实际存在 `bbr` 时才启用。

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
- [MMWX](https://github.com/iluobei/miaomiaowu)：节点管理与订阅工具。

## License

[MIT](LICENSE)
