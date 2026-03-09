---
name: douyin-scraper
description: Use the upstream afengzi/douyin_scapy project in a repeatable, operator-safe way for Douyin login, historical scraping, optional monitoring, image/frame capture, OCR, and optional Redis/webhook integration. Only use when the operator owns the account or has a legitimate compliance basis.
---

# Douyin Scraper

把 `afengzi/douyin_scapy` 封装成一个**可初始化、可运行、可最小验收**的 OpenClaw skill，而不是只给说明。

这个 skill 不直接内置上游源码；它提供一条明确的上游获取路径，以及更稳妥的初始化、运行、校验脚本。

## 适用边界

适合：

- 用户明确要求抓取自己可合法访问的抖音创作者页面。
- 需要下载图文作品，或从视频提取首帧做 OCR。
- 需要把 OCR 结果写入 Redis，或继续做结构化提取。
- 需要在人工登录后做短周期监控验证。

不适合：

- 授权不清、用途不清、合规基础不清的抓取。
- 试图绕过平台风控、隐藏身份、批量盗采、分享登录态。
- 要求把 `.env`、`cookies.json`、日志、下载产物打包回传。

## skill 内文件

- `scripts/fetch-upstream.sh`：克隆或更新上游 `afengzi/douyin_scapy`
- `scripts/bootstrap.sh`：检查依赖、建立虚拟环境、安装 Python 依赖与 Playwright Chromium
- `scripts/run-douyin.sh`：统一运行入口，带前置检查和更清晰的报错
- `scripts/verify-skill.sh`：对 skill 结构和脚本做最小可交付校验
- `references/upstream-analysis.md`：上游能力与风险说明

## 推荐工作流

### 1) 获取上游代码

默认会放到：

```bash
/home/node/.openclaw/workspace/repos/douyin_scapy
```

执行：

```bash
{baseDir}/scripts/fetch-upstream.sh
```

也可以指定目录或分支：

```bash
{baseDir}/scripts/fetch-upstream.sh --dest /tmp/douyin_scapy --ref main
```

脚本会：

- 首次运行时 `git clone` 上游仓库；
- 已存在仓库时执行 `git fetch` + `git pull --ff-only`；
- 检查 `main.py` / `requirements.txt` / `config.py` / `.env.example` 是否齐全；
- 给出下一步初始化提示。

## 2) 初始化运行环境

```bash
{baseDir}/scripts/bootstrap.sh /home/node/.openclaw/workspace/repos/douyin_scapy
```

默认行为：

- 检查 `python3` / `git` 是否存在；
- 在上游目录创建或复用 `.venv`；
- 安装 `requirements.txt`；
- 补装上游漏写但代码实际会 import 的 `openai` / `pydantic`；
- 安装 Playwright Chromium。

只做预检、不真正安装：

```bash
{baseDir}/scripts/bootstrap.sh /home/node/.openclaw/workspace/repos/douyin_scapy --dry-run
```

## 3) 按需配置

上游仍需要人工配置运行参数，这是正常的。

至少检查：

- `.env`：从 `.env.example` 复制后按需填写 Redis / webhook / LLM 配置
- `config.py`：替换默认示例 `TARGET_USERS`，确认 `SAVE_DIR`、`MONITOR_INTERVAL`、`MONITOR_TIME_WINDOW`

建议：

```bash
cd /home/node/.openclaw/workspace/repos/douyin_scapy
cp .env.example .env
```

## 4) 人工扫码登录（必要交互）

首次登录需要操作者亲自扫码，agent 不能替代。

```bash
{baseDir}/scripts/run-douyin.sh /home/node/.openclaw/workspace/repos/douyin_scapy --login
```

说明：

- 这一步会打开浏览器；
- 需要人工完成抖音扫码登录；
- 成功后通常会生成或更新 `cookies.json`；
- `cookies.json` 属于敏感登录态文件，不应提交到 skill 仓库。

## 5) 运行抓取 / 监控

仅抓历史：

```bash
{baseDir}/scripts/run-douyin.sh /home/node/.openclaw/workspace/repos/douyin_scapy --scrape
```

仅监控：

```bash
{baseDir}/scripts/run-douyin.sh /home/node/.openclaw/workspace/repos/douyin_scapy --monitor --interval 300
```

历史抓取 + 监控：

```bash
{baseDir}/scripts/run-douyin.sh /home/node/.openclaw/workspace/repos/douyin_scapy --all
```

## 最小验收流程

下面这套流程不要求真实账号内容，也不要求真实 cookie 回传；目标是证明 skill 已经接近“真正可用”。

### A. 结构校验

```bash
{baseDir}/scripts/verify-skill.sh
```

应至少通过：

- `SKILL.md` frontmatter 只包含 `name` / `description`
- 必要脚本存在且可解析
- 未把 `.env`、cookies、日志、下载目录等敏感或运行态产物塞进 skill

### B. 上游获取校验

```bash
{baseDir}/scripts/fetch-upstream.sh --dest /tmp/douyin-skill-check
```

应能完成 clone，并检测到关键文件。

### C. 初始化预检

```bash
{baseDir}/scripts/bootstrap.sh /tmp/douyin-skill-check --dry-run
```

应能通过依赖和文件检查。

### D. 运行入口预检

```bash
{baseDir}/scripts/run-douyin.sh /tmp/douyin-skill-check --help
```

应能打印帮助；
如执行 `--login`，需明确提示人工扫码登录。

### E. 真实功能最小人工验收（需要操作者参与）

在合法授权前提下，可由操作者自行做一轮：

1. `run-douyin.sh ... --login`
2. 人工扫码完成登录
3. 将 `config.py` 中 `TARGET_USERS` 改成自己的目标
4. `run-douyin.sh ... --scrape`
5. 确认出现下载目录或首帧文件
6. 如配置了 Redis / webhook，再分别验证写入与通知

## 失败排查

### `python3 not found` / `git not found`

先补系统依赖，再重新执行 `bootstrap.sh`。

### `requirements.txt not found` / `main.py not found`

通常是：

- 传入了错误目录；
- 上游仓库未完整 clone；
- 目录不是 `douyin_scapy` 根目录。

优先重新运行：

```bash
{baseDir}/scripts/fetch-upstream.sh --dest /some/clean/path
```

### Playwright / Chromium 相关报错

重新执行：

```bash
{baseDir}/scripts/bootstrap.sh /path/to/douyin_scapy
```

如果宿主机缺系统依赖，按 Playwright/Chromium 的缺失提示补齐。

### `cookies.json` 不存在或登录后仍抓不到内容

- 先确认操作者确实完成了扫码登录；
- 检查浏览器是否被关闭过早；
- 再次执行 `--login`；
- 注意平台页面结构变化也可能导致登录态初始化失效。

### Redis / webhook / LLM 报错

这些是可选功能。

- 先只验证 `--login` + `--scrape` 主链路；
- 再单独检查 `.env` 中对应配置；
- 上游 `requirements.txt` 未显式列出全部 LLM 依赖，所以 `bootstrap.sh` 已补装 `openai` / `pydantic`。

### `config.py` 里还是默认示例目标

这是上游遗留问题，不适合作为生产默认值。运行前必须人工替换成自己的目标用户配置。

## 交付边界

这个 skill 刻意**不包含**以下内容：

- 上游源码本体
- `.env`
- `cookies.json`
- `download_history.json`
- `douyin_scraper.log`
- `downloads/`
- `stock_list.json`
- `__pycache__/`
- `.venv/`
- 任何真实 webhook、密码、cookie、真实目标账号列表

## 当前仍受上游限制的点

- 页面结构变化会影响抓取稳定性；
- `config.py` 仍由上游维护，默认示例目标需要人工替换；
- 严格意义上的功能验收仍需要人工扫码登录；
- 若要做真实抓取验证，必须由操作者在合法授权下完成。
