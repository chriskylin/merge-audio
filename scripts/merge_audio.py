#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
merge_audio.py —— 将多段音频录音拼接为单个文件。

原理：用 ffmpeg 的 concat 滤镜「先解码、再重编码」，并在拼接前用 aformat 把每段
统一到相同采样率/声道布局，因此不挑各段参数（采样率、声道数、封装不同也能拼）。
只对源文件做读取，只新建一个输出文件，绝不改动/删除原件。

依赖：ffmpeg + ffprobe（Windows 常见位置见 find_ffmpeg；否则回退到 PATH）。

用法：
  # 整个文件夹按文件名升序拼接（文件名含时间戳最可靠）
  python merge_audio.py --folder "C:/x/飞书录音" --ext aac --output merged.mp3

  # 显式指定若干文件（已按你给的顺序）
  python merge_audio.py --files a.m4a b.m4a c.mp3 --output out.mp3

  # 按文件系统修改时间排序
  python merge_audio.py --folder "C:/x" --ext mp3 --order mtime --output out.mp3

  # 段与段之间留 1 秒静音
  python merge_audio.py --folder "C:/x" --gap 1 --output out.mp3

  # 输出为无损 wav / 苹果 m4a
  python merge_audio.py --folder "C:/x" --format wav --output out.wav
  python merge_audio.py --folder "C:/x" --format m4a --output out.m4a
"""
import argparse, subprocess, glob, os, json, sys

def find_ffmpeg():
    for c in [
        r"C:\Users\ChrisChung\bin\ffmpeg.exe",
        r"C:\Users\ChrisChung\.workbuddy\binaries\ffmpeg\ffmpeg.exe",
    ]:
        if os.path.exists(c):
            return c
    return "ffmpeg"

def probe(path, ffprobe):
    r = subprocess.run([ffprobe, "-v", "error", "-show_streams", "-show_format",
                        "-of", "json", path], capture_output=True, text=True, encoding="utf-8")
    info = json.loads(r.stdout)
    astream = next(s for s in info["streams"] if s.get("codec_type") == "audio")
    dur = float(info["format"].get("duration", astream.get("duration", 0)))
    return int(astream.get("sample_rate", 44100)), int(astream.get("channels", 1)), dur

def codec_for(fmt):
    return {"mp3": "libmp3lame", "m4a": "aac", "wav": "pcm_s16le"}[fmt]

def main():
    ap = argparse.ArgumentParser(description="将多段音频拼接为单个文件")
    ap.add_argument("--folder", help="输入文件夹（配合 --ext 通配）")
    ap.add_argument("--files", nargs="+", help="显式文件清单（按给定顺序）")
    ap.add_argument("--ext", default="aac", help="文件夹模式下的扩展名，默认 aac")
    ap.add_argument("--order", choices=["filename", "mtime"], default="filename",
                   help="排序方式：filename=按文件名升序（含时间戳最可靠）；mtime=按修改时间")
    ap.add_argument("--output", required=True, help="输出文件路径")
    ap.add_argument("--bitrate", default="128k", help="有损格式码率，默认 128k（语音够用）")
    ap.add_argument("--format", choices=["mp3", "m4a", "wav"], default="mp3", help="输出格式")
    ap.add_argument("--gap", type=float, default=0.0, help="段间静音秒数，默认 0（无缝）")
    args = ap.parse_args()

    ffmpeg = find_ffmpeg()
    ffprobe = "ffprobe"
    d = os.path.dirname(ffmpeg)
    if d and os.path.exists(os.path.join(d, "ffprobe.exe")):
        ffprobe = os.path.join(d, "ffprobe.exe")

    # 1) 收集并排序
    if args.files:
        files = list(args.files)
    elif args.folder:
        files = glob.glob(os.path.join(args.folder, f"*.{args.ext}"))
    else:
        print("ERROR: 需提供 --folder 或 --files"); sys.exit(1)

    if args.order == "mtime":
        files.sort(key=lambda f: os.path.getmtime(f))
    else:
        files.sort(key=lambda f: os.path.basename(f))

    if not files:
        print("ERROR: 未找到音频文件"); sys.exit(1)

    print(f"共 {len(files)} 个文件，拼接顺序：")
    for f in files:
        print("   ", os.path.basename(f))

    # 2) 探测参数
    params = [probe(f, ffprobe) for f in files]
    srs = [p[0] for p in params]
    chs = [p[1] for p in params]
    durs = [p[2] for p in params]
    target_sr = max(set(srs), key=srs.count)   # 最常见的采样率
    target_ch = max(chs)                         # 最大声道数（避免丢声道）
    layout = "mono" if target_ch == 1 else "stereo"
    print(f"统一参数: sample_rate={target_sr}, channels={target_ch} ({layout})")
    print(f"各段时长(秒): {[round(d, 1) for d in durs]}  预计总时长≈{sum(durs)/60:.1f} 分钟")

    # 3) 构建输入与 filter_complex
    inputs = []
    for f in files:
        inputs += ["-i", f]
    real_count = len(files)
    nodes = []
    concat_ins = []
    silence_count = 0
    for i in range(real_count):
        nodes.append(f"[{i}:a]aformat=sample_rates={target_sr}:channel_layouts={layout}[a{i}]")
        concat_ins.append(f"[a{i}]")
        if args.gap > 0 and i < real_count - 1:
            sil_idx = real_count + silence_count
            silence_count += 1
            inputs += ["-f", "lavfi", "-i",
                       f"anullsrc=channel_layout={layout}:sample_rate={target_sr}:duration={args.gap}"]
            nodes.append(f"[{sil_idx}:a]aformat=sample_rates={target_sr}:channel_layouts={layout}[s{i}]")
            concat_ins.append(f"[s{i}]")
    total_inputs = real_count + silence_count
    filter_complex = ";".join(nodes) + ";" + "".join(concat_ins) + f"concat=n={total_inputs}:v=0:a=1[out]"

    # 4) 编码
    codec = codec_for(args.format)
    cmd = [ffmpeg, "-y", "-hide_banner"] + inputs + [
        "-filter_complex", filter_complex, "-map", "[out]", "-c:a", codec]
    if args.format != "wav":
        cmd += ["-b:a", args.bitrate]
    cmd += [args.output]

    print("\n运行 ffmpeg 拼接中...\n")
    r = subprocess.run(cmd, capture_output=True, text=True, encoding="utf-8")
    if r.returncode != 0:
        print("FFMPEG 失败，返回码", r.returncode)
        print("STDERR 末尾:\n", r.stderr[-2000:])
        sys.exit(1)

    # 5) 校验总时长
    out_dur = probe(args.output, ffprobe)[2]
    expected = sum(durs) + silence_count * args.gap
    diff = out_dur - expected
    print(f"\n输出文件: {args.output}")
    print(f"输出总时长 = {out_dur/60:.2f} 分钟 ({out_dur:.1f}s)")
    print(f"各段之和   = {expected/60:.2f} 分钟 ({expected:.1f}s)")
    print(f"差值       = {diff:+.1f}s")
    if abs(diff) > 3:
        print("WARNING: 时长偏差 > 3 秒，请检查是否漏段/重复。")
    else:
        print("OK: 时长吻合，拼接完整。")
    print("完成。")

if __name__ == "__main__":
    main()
