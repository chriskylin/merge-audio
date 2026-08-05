# merge-audio

把多段录音 / 音频片段拼接成一段的 **WorkBuddy skill**。基于 `ffmpeg`，支持跨格式、参数归一化与段间静音，最后用 `ffprobe` 校验总时长。

## 功能

- 输入：整个文件夹通配，或显式指定文件清单
- 排序：按文件名时间戳（推荐，最稳）、或按文件修改时间
- 输出：`mp3` / `m4a` / `wav`，码率可调
- 段间衔接：无缝直连，或 `--gap` 留静音停顿
- 自动处理：各段采样率 / 声道不一致时，先用 `aformat` 统一再拼接，避免中途崩
- 校验：拼完用 `ffprobe` 核对总时长 ≈ 各段之和

## 依赖

- `ffmpeg` / `ffprobe`：需已在 `PATH` 中（脚本只调用命令行，不依赖 Python 包）
- Python 3：仅用标准库（脚本 `scripts/merge_audio.py`）

## 安装

### 方式一：从源码安装（推荐，便于后续改）

把本仓库克隆 / 复制到 WorkBuddy 的 skills 目录即可被识别：

```bash
git clone https://github.com/chriskylin/merge-audio.git ~/.workbuddy/skills/merge-audio
```

### 方式二：加载 `.skill` 包

在 WorkBuddy 的 skill 管理界面导入 `merge-audio.skill` 即可（本仓库的 Release 里提供打包文件）。

## 用法

### 在 WorkBuddy 里

直接说「把这几个录音拼一下 / 合并音频」，skill 会自动读取你的文件夹、确认顺序与输出格式后执行。

### 命令行直接跑脚本

```bash
python scripts/merge_audio.py \
  --folder "C:/Users/你/Desktop/录音" \
  --ext aac \
  --sort filename \
  --output "C:/Users/你/Desktop/录音/合并.mp3" \
  --bitrate 192k
```

### 常用参数

| 参数 | 说明 | 默认 |
|------|------|------|
| `--folder` | 源文件夹（与 `--files` 二选一） | — |
| `--files` | 显式文件清单（空格分隔） | — |
| `--ext` | 文件夹模式下要合并的扩展名 | `mp3` |
| `--sort` | `filename`（文件名时间戳）或 `mtime`（修改时间） | `filename` |
| `--output` | 输出文件路径 | 必填 |
| `--bitrate` | mp3/m4a 码率，如 `64k` `128k` `192k` | `128k` |
| `--gap` | 段间静音秒数（0 = 无缝直连） | `0` |
| `--format` | 输出格式，由 `--output` 后缀决定，可强制 | 自动 |

## 安全边界

- 只**读取**源文件、**新建**一个合并文件
- **绝不删除 / 移动 / 改写**任何源音频文件

## 踩坑笔记

- 飞书录音实际是 `.aac`（AAC 编码）而非 `m4a`，ffmpeg 同样能解
- 用「修改时间」排序常有并列（同一秒录制多段），优先用文件名时间戳排序
- 16kHz 的语音源用 192k 属于过度保真，文件虚大；语音场景 `64k`–`128k` 已足够清晰
