#!/usr/bin/env bash
set -euo pipefail
mkdir -p wangluobin-render/{src,segments,out}
cd wangluobin-render

fetch_img() {
  local name="$1" url="$2" referer="$3"
  echo "Downloading $name"
  if curl -fL --retry 3 --connect-timeout 15 --max-time 90 \
    -A 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/131 Safari/537.36' \
    -e "$referer" "$url" -o "src/$name"; then
      if ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "src/$name" >/dev/null 2>&1; then return 0; fi
  fi
  rm -f "src/$name"; return 1
}

# 只用可核验公开真人/史料照片；具体节点无图则复用同人物/同阶段真人照，不生成AI历史场景。
fetch_img portrait.jpg 'https://i2.chinanews.com/simg/hnhd/2023/11/29/45/3141091278417735329.jpg' 'https://www.chinanews.com.cn/' || true
fetch_img manuscript.jpg 'https://i2.chinanews.com/simg/hnhd/2023/11/29/7/16032249885843546467.jpg' 'https://www.chinanews.com.cn/' || true
fetch_img early.jpg 'https://x0.ifengimg.com/ucms/2021_50/E3E8935B15D32A42CAA4E66365A054827A95E931_size52_w746_h703.jpg' 'https://gs.ifeng.com/' || true
fetch_img lanzhou.jpg 'https://x0.ifengimg.com/ucms/2021_12/15026DD6B9F7C70751E72387CB3E5975D511E46D_size40_w768_h726.jpg' 'https://gs.ifeng.com/' || true
fetch_img xiaojun.jpg 'https://x0.ifengimg.com/ucms/2021_12/A9701201F825608C340C1A4ADB53EE2C800E4CC2_size26_w399_h300.jpg' 'https://gs.ifeng.com/' || true
fetch_img prison.png 'https://x0.ifengimg.com/res/2020/00FA35A57C5BCEA0FCF26ED1F30212BB63582367_size632_w833_h566.png' 'https://www.ifeng.com/' || true
fetch_img piano.png 'https://media.bjnews.com.cn/image/2025/06/14/5598003721448532979.png' 'https://www.bjnews.com.cn/' || true
fetch_img uniform.jpg 'https://k.sinaimg.cn/n/sinakd20230414s/491/w640h651/20230414/201f-28aa401a5f07d8f2d41300d708c715ab.jpg/w700d1q75cms.jpg?by=cms_fixed_width' 'https://www.sina.com.cn/' || true
fetch_img bookstore.jpg 'https://i2.chinanews.com/simg/hnhd/2023/11/29/64/8714948600698490096.jpg' 'https://www.chinanews.com.cn/' || true
fetch_img sanmao1.jpg 'https://n.sinaimg.cn/sinakd20116/203/w1024h779/20221021/ab33-900b63933a7af7b4041b0a5eb3df0609.jpg' 'https://www.sina.com.cn/' || true
fetch_img sanmao2.jpg 'https://media.bjnews.com.cn/cover/2025/06/14/5597918564158873775.jpg' 'https://www.bjnews.com.cn/' || true
fetch_img sanmao_piano.jpg 'https://media.bjnews.com.cn/cover/2025/06/14/5597918565152924553.jpg' 'https://www.bjnews.com.cn/' || true
fetch_img taiwan_press.jpg 'https://i2.chinanews.com/simg/hnhd/2023/11/29/68/8316959810859968144.jpg' 'https://www.chinanews.com.cn/' || true
fetch_img taiwan_group.jpg 'https://g.udn.com.tw/upfiles/B_ME/melyang2008/PSN_PHOTO/416/f_7741416_1.jpg' 'https://udn.com/' || true
fetch_img liangan.jpg 'https://i2.chinanews.com/simg/hnhd/2023/11/29/95/15747710494210093215.jpg' 'https://www.chinanews.com.cn/' || true

if [[ ! -f src/portrait.jpg ]]; then fetch_img portrait.jpg 'https://www.krzzjn.com/uploadfile/2020/0703/20200703032538391.jpg' 'https://www.krzzjn.com/' || true; fi
if [[ ! -f src/portrait.jpg ]]; then fetch_img portrait.jpg 'https://bkimg.cdn.bcebos.com/pic/500fd9f9d72a6059252defb3d468239b033b5bb50c5f' 'https://baike.baidu.com/' || true; fi
[[ -f src/portrait.jpg ]] || { echo 'No verified Wang Luobin image could be downloaded'; exit 2; }

fallback() { [[ -f "src/$1" ]] || cp "src/$2" "src/$1"; }
fallback manuscript.jpg portrait.jpg
fallback early.jpg portrait.jpg
fallback lanzhou.jpg early.jpg
fallback xiaojun.jpg lanzhou.jpg
fallback prison.png portrait.jpg
fallback piano.png portrait.jpg
fallback uniform.jpg portrait.jpg
fallback bookstore.jpg portrait.jpg
fallback sanmao1.jpg portrait.jpg
fallback sanmao2.jpg sanmao1.jpg
fallback sanmao_piano.jpg sanmao1.jpg
fallback taiwan_press.jpg portrait.jpg
fallback taiwan_group.jpg taiwan_press.jpg
fallback liangan.jpg manuscript.jpg

make_segment() {
  local idx="$1" src="$2" dur="$3" zoom="$4"
  echo "Rendering $idx $src $dur"
  ffmpeg -hide_banner -loglevel error -y -loop 1 -framerate 30 -i "src/$src" -t "$dur" \
    -filter_complex "[0:v]split=2[bg][fg];[bg]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=24:2,eq=brightness=-0.18[bg2];[fg]scale=1000:1720:force_original_aspect_ratio=decrease[fg2];[bg2][fg2]overlay=(W-w)/2:(H-h)/2,zoompan=z='min(1+${zoom}*on,1.055)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=1080x1920:fps=30,format=yuv420p[v]" \
    -map '[v]' -an -c:v libx264 -preset ultrafast -crf 26 -r 30 -pix_fmt yuv420p "segments/${idx}.mp4"
}

# 每段持续到下一语义切换点，合计严格 673.0 秒。
make_segment 01 portrait.jpg 14.3 0.00010
make_segment 02 manuscript.jpg 15.0 0.00008
make_segment 03 early.jpg 28.5 0.00008
make_segment 04 lanzhou.jpg 14.2 0.00010
make_segment 05 xiaojun.jpg 11.8 0.00012
make_segment 06 xiaojun.jpg 20.6 0.00006
make_segment 07 early.jpg 22.6 0.00008
make_segment 08 lanzhou.jpg 21.9 0.00007
make_segment 09 manuscript.jpg 29.2 0.00007
make_segment 10 early.jpg 33.4 0.00006
make_segment 11 manuscript.jpg 42.6 0.00005
make_segment 12 prison.png 33.0 0.00007
make_segment 13 prison.png 45.7 0.00005
make_segment 14 piano.png 29.1 0.00007
make_segment 15 uniform.jpg 18.5 0.00009
make_segment 16 piano.png 32.8 0.00006
make_segment 17 piano.png 31.1 0.00007
make_segment 18 bookstore.jpg 24.1 0.00008
make_segment 19 sanmao1.jpg 25.3 0.00008
make_segment 20 sanmao2.jpg 29.3 0.00007
make_segment 21 sanmao_piano.jpg 20.8 0.00009
make_segment 22 taiwan_press.jpg 14.2 0.00010
make_segment 23 taiwan_group.jpg 13.6 0.00011
make_segment 24 liangan.jpg 15.7 0.00010
make_segment 25 portrait.jpg 19.4 0.00009
make_segment 26 piano.png 24.0 0.00008
make_segment 27 manuscript.jpg 18.5 0.00009
make_segment 28 portrait.jpg 23.8 0.00008

: > concat.txt
for f in segments/*.mp4; do echo "file '$PWD/$f'" >> concat.txt; done
ffmpeg -hide_banner -loglevel error -y -f concat -safe 0 -i concat.txt -c copy -movflags +faststart out/wangluobin_video_only.mp4
ffprobe -v error -show_entries format=duration,size -of default=nw=1 out/wangluobin_video_only.mp4
