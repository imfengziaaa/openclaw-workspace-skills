---
name: douyin-scraper
description: Wrap the afengzi/douyin_scapy project as an OpenClaw skill for Douyin creator scraping, image/video-frame capture, OCR extraction, optional Redis persistence, and scheduled monitoring. Use only when the operator explicitly owns the target account/cookies or has a legitimate compliance basis to collect the content.
homepage: https://github.com/afengzi/douyin_scapy
metadata:
  {
    "openclaw": {
      "emoji": "🎵",
      "requires": {
        "bins": ["python3", "git", "ffmpeg"],
        "env": []
      }
    }
  }
---

# Douyin Scraper

把 `afengzi/douyin_scapy` 封装成一个可复用的 OpenClaw skill，供 agent 在明确授权、明确目标、明确合规边界时调用。

## 何时触发

适合这些任务：

- 用户明确要求抓取某个抖音主页的公开图文作品。
- 用户需要下载图文原图，或从视频提取首帧做 OCR。
- 用户需要把 OCR 结果写入 Redis，或继续做结构化提取。
- 用户要做定时巡检：检查是否有新作品并发送 webhook 通知。

不适合这些任务：

- 不明确是否合法、是否得到授权的抓取。
- 试图绕过平台风控、批量盗采、撞库、刷接口、隐藏身份等高风险行为。
- 要求导出、分享或提交 `cookies.json`、`.env`、日志、下载产物等敏感/运行态文件。

## 上游项目摘要

上游仓库是一个 **Playwright + HTTP 下载 + ffmpeg + RapidOCR + Redis** 的组合工具，能力包括：

1. 打开抖音主页并获取/复用 cookie。
2. 抓取目标用户作品列表。
3. 对图文作品下载原图；对视频尝试抽取高清首帧。
4. 对图片做 OCR。
5. 可选写入 Redis，并通过 LLM/正则补充结构化信息。
6. 可选进入定时监控并走企业微信/钉钉 webhook 通知。

## 主要入口与关键文件

- `main.py`：主入口，支持 `--login` / `--scrape` / `--monitor` / `--all`
- `douyin_api.py`：Playwright 浏览器启动、cookie 加载、页面抓取、视频帧提取
- `downloader.py`：图片/首帧下载与去重记录
- `monitor.py`：轮询监控、异常重连、时间窗口控制
- `ocr_redis.py`：RapidOCR + Redis 写入 + 结构化提取
- `llm_extractor.py`：可选 OpenAI-compatible LLM 提取
- `stock_lookup.py`：股票名称/代码补全缓存
- `config.py`：目标用户、目录、时间窗口、Redis、Webhook、LLM 等配置
- `.env.example`：敏感环境变量模板

## 依赖与环境

### 系统依赖

- `python3`
- `ffmpeg`
- Playwright Chromium 运行环境

### Python 依赖

参考上游 `requirements.txt`：

- `playwright`
- `httpx`
- `loguru`
- `apscheduler`
- `imageio-ffmpeg`
- `redis`
- `rapidocr-onnxruntime`
- `python-dotenv`

如果要启用 LLM 结构化提取，上游代码还隐含需要：

- `openai`
- `pydantic`

> 注意：上游 `requirements.txt` 当前**未显式列出** `openai` / `pydantic`，这属于可用性缺口。实际运行 LLM 提取前应补装。

## 配置方法

### 1) 复制环境变量模板

```bash
cd /path/to/douyin_scapy
cp .env.example .env
```

然后按需填写：

- `REDIS_HOST`
- `REDIS_PORT`
- `REDIS_PASSWORD`
- `REDIS_DB`
- `WECHAT_WEBHOOK`
- `DINGTALK_WEBHOOK`
- `LLM_API_BASE`
- `LLM_MODEL_NAME`
- `LLM_API_KEY`

### 2) 修改 `config.py`

重点看：

- `TARGET_USERS`
- `MONITOR_INTERVAL`
- `MONITOR_TIME_WINDOW`
- `SAVE_DIR`
- `BROWSER_HEADLESS`

> 默认仓库里写死了一个 `TARGET_USERS` 示例地址。实际复用时应替换成你自己的目标，避免误抓别人的页面。

## 推荐运行方式

### 首次登录

```bash
python3 main.py --login
```

### 历史抓取

```bash
python3 main.py --scrape
```

### 仅监控

```bash
python3 main.py --monitor --interval 300
```

### 历史抓取 + 监控

```bash
python3 main.py --all
```

## 在 OpenClaw 里怎么安全用

推荐 agent 按这个顺序操作：

1. 先确认目标账号、用途、授权和保存范围。
2. 检查 `.env`、`cookies.json`、`download_history.json` 是否已存在。
3. 必要时用可见浏览器执行一次 `--login`，让操作者扫码。
4. 先跑单用户、小范围验证，不要直接长时间监控。
5. 如需监控，再开启 `--monitor` / `--all`。
6. 输出结论时只返回统计、路径、摘要，不回传 cookie、webhook、原始敏感配置。

## 快速验证清单

最小验证建议：

1. `python3 -m pip install -r requirements.txt`
2. `python3 -m playwright install chromium`
3. `python3 main.py --login` 成功生成 `cookies.json`
4. `python3 main.py --scrape` 能下载至少一个作品目录
5. 若配了 Redis：确认出现 `douyin:ocr:*` 记录
6. 若配了 Webhook：新作品通知能成功发出

## 这个 skill 刻意不带入的内容

以下内容属于**敏感信息、运行态垃圾或不可复用产物**，不应纳入 skill：

- `.git/`
- `.env`
- `cookies.json`
- `download_history.json`
- `douyin_scraper.log`
- `downloads/`
- `stock_list.json`（运行时缓存）
- `__pycache__/`
- `dist/` / `build/` / `.venv/`
- 任何真实 webhook、真实 Redis 密码、真实目标账号清单

## 限制与风险

### 平台与合规风险

- 抖音抓取受平台条款、访问频率、反爬策略约束。
- 即便是公开内容，也不代表可以任意大规模抓取、商用、转载或二次分发。
- 登录态 cookie 涉及账号安全，必须由账号持有人自行扫码、保管和撤销。

### 技术风险

- 页面结构和接口随时可能变化，Playwright 拦截逻辑可能失效。
- 高频轮询、批量多账号抓取容易触发风控。
- OCR 对图片质量敏感，视频首帧不一定包含有效文字。
- Redis、Webhook、LLM 都是可选依赖；任何一个不可用都可能导致部分流程降级。
- `monitor.py` 注释写“上海时间”，但当前实现用的是本机 `datetime.now()`，严格时区一致性要靠运行环境自己保证。

### 仓库可维护性缺口

- `requirements.txt` 没列全 LLM 依赖。
- `config.py` 内含硬编码目标用户示例，不适合作为通用默认值。
- 测试脚本依赖真实 Redis key 和真实数据，不适合作为通用 skill 自测。

## 建议的 skill 使用姿势

如果 agent 只是需要“会用这个项目”，优先：

- 复用这个 skill 的说明；
- 用 `scripts/bootstrap.sh` 快速准备环境；
- 用 `scripts/run-douyin.sh` 统一执行命令；
- 在独立工作目录保存运行产物；
- 对外只报告必要结果，不暴露账号态数据。

## 附带文件

- `references/upstream-analysis.md`：上游项目分析与筛选结论
- `scripts/bootstrap.sh`：初始化依赖与 Playwright
- `scripts/run-douyin.sh`：包装运行入口

