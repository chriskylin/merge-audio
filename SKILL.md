---
name: merge-audio
description: 将多段音频录音/片段拼接合并为单个音频文件（mp3/m4a/wav 等），基于 ffmpeg。当用户想把多段录音、语音备忘录、播客片段、会议音频合并成一段时触发；也适用于用户问「有什么软件能把几个录音拼一起」「帮我合并音频」。覆盖：按文件名时间戳或修改时间排序、跨格式/跨参数归一化拼接、输出格式与码率选择、段间静音、ffprobe 时长校验。
---

# 合并音频（merge-audio）

把多个音频文件合成一个连续的音频文件。核心工具是 **ffmpeg**（本机已装，路径见脚本 `scripts/merge_audio.py` 的 `find_ffmpeg`）。

## 何时用
- 用户有多段录音/片段要拼成一段（如飞书录音、会议录音、播客、语音备忘录）。
- 用户问「有什么软件能合并录音」「帮我拼接音频」。

## 工作流
1. **确认输入**：问清文件夹路径或文件清单、源格式、排序依据、输出格式/码率、是否需要段间静音。
2. **排序**：优先按**文件名内的时间戳**升序（最可靠）；仅在文件名无时间信息时退而求其次用修改时间（mtime）。
3. **运行脚本**：调用 `scripts/merge_audio.py`，它负责探测参数、用 `aformat` 统一各段再 `concat` 滤镜重编码、最后用 ffprobe 校验总时长。

```bash
# 整个文件夹按文件名拼接（推荐）
python scripts/merge_audio.py --folder "C:/路径/飞书录音" --ext aac --output merged.mp3

# 显式清单、按给定顺序
python scripts/merge_audio.py --files a.m4a b.mp3 --output out.mp3

# 段间留 1 秒静音 / 输出 m4a 或 wav
python scripts/merge_audio.py --folder "C:/x" --gap 1 --output out.mp3
python scripts/merge_audio.py --folder "C:/x" --format m4a --output out.m4a
```

可选参数：`--order {filename,mtime}`、`--bitrate`（默认 128k）、`--format {mp3,m4a,wav}`、`--gap 秒数`。

## 关键坑（务必注意）
- **修改时间会有并列**：同一批录音里常出现 mtime 完全相同的文件（如两组都在同一分钟写入），按 mtime 排序会错乱。飞书等录音文件名通常内嵌时间戳（`飞书录音_20260804195800.aac`），按文件名排序可避免歧义。
- **实际格式可能是 .aac 而非 m4a**：飞书导出常为 `.aac`（AAC 编码），ffmpeg 直接可解，不影响拼接，但别被用户口述的「m4a」误导。
- **各段参数不一致**：采样率/声道数不同会导致 concat 滤镜报错。脚本已用 `aformat=sample_rates=...:channel_layouts=...` 在拼接前统一，无需手动处理。
- **码率够用即可**：录音源常只有 16kHz 采样率，192k 属于过度保真、文件偏大。语音场景 64–128k 已透明；除非含音乐或需后期再编辑，否则不必上 192k。

## 安全边界
- 只读取源文件、只新建一个输出文件；**绝不删除/移动/改写任何原始音频**。
- 输出文件默认放到用户输入目录内，命名清晰（如 `merged.mp3`）；若用户更希望放别处，先确认路径。

## 校验
脚本结尾会用 ffprobe 比对「输出总时长」与「各段之和（含静音）」，差值 >3 秒会告警，提示可能漏段或重复。
