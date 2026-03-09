# Upstream analysis: afengzi/douyin_scapy

## Purpose

A Douyin creator scraper/monitor that:

- uses Playwright to access creator pages and cookies,
- downloads image posts or extracts a first frame from video posts,
- runs RapidOCR on saved images,
- optionally stores OCR/structured output into Redis,
- optionally pushes notifications to WeCom/DingTalk webhooks,
- supports scheduled monitoring.

## Main entrypoints

- `main.py`: CLI entry
- `douyin_api.py`: browser/session/data acquisition
- `downloader.py`: local media persistence and history tracking
- `monitor.py`: polling loop and reconnect logic
- `ocr_redis.py`: OCR + Redis write path

## Notable dependencies

- Required: Playwright, ffmpeg, httpx, rapidocr-onnxruntime, redis, python-dotenv
- Optional but effectively needed for full structured extraction: `openai`, `pydantic`

## Configuration surfaces

- `.env` for Redis / webhook / LLM secrets
- `config.py` for target users, paths, polling window, browser settings
- `cookies.json` generated after login
- `download_history.json` generated for dedupe state

## Sensitive or non-reusable content to exclude from skill packaging

- `.env`
- `cookies.json`
- `download_history.json`
- `downloads/`
- `douyin_scraper.log`
- `stock_list.json`
- `.git/`
- `__pycache__/`, build artifacts, caches
- real webhook URLs / passwords / real cookie material

## Packaging decision

Single skill is enough.

Chosen skill name: `douyin-scraper`

Reasoning:

- concise,
- describes the reusable operator action,
- avoids leaking the upstream typo `scapy`,
- covers scraping + OCR + monitoring in one coherent workflow.

## Included helper scripts

- `scripts/bootstrap.sh`: install Python deps and Playwright Chromium
- `scripts/run-douyin.sh`: safer wrapper around `python3 main.py ...`

## Known upstream gaps

1. `requirements.txt` does not include all LLM-related packages used by `llm_extractor.py`.
2. `config.py` contains a concrete sample target user, which should be replaced before production use.
3. test files depend on real Redis data and are not suitable as generic skill fixtures.
4. monitor time-window comments mention Shanghai time, but implementation depends on host local time.
