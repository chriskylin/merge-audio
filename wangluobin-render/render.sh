#!/usr/bin/env bash
set -euo pipefail
mkdir -p wangluobin-render/{src,frames,out}
cd wangluobin-render
UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/131 Safari/537.36'
fetch_img(){ n="$1"; u="$2"; r="$3"; echo "GET $n"; curl -fsSL --connect-timeout 8 --max-time 20 -A "$UA" -e "$r" "$u" -o "src/$n" && ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "src/$n" >/dev/null 2>&1 || rm -f "src/$n"; }

{ fetch_img portrait.jpg 'https://i2.chinanews.com/simg/hnhd/2023/11/29/45/3141091278417735329.jpg' 'https://www.chinanews.com.cn/'; } &
{ fetch_img manuscript.jpg 'https://i2.chinanews.com/simg/hnhd/2023/11/29/7/16032249885843546467.jpg' 'https://www.chinanews.com.cn/'; } &
{ fetch_img early.jpg 'https://x0.ifengimg.com/ucms/2021_50/E3E8935B15D32A42CAA4E66365A054827A95E931_size52_w746_h703.jpg' 'https://gs.ifeng.com/'; } &
{ fetch_img lanzhou.jpg 'https://x0.ifengimg.com/ucms/2021_12/15026DD6B9F7C70751E72387CB3E5975D511E46D_size40_w768_h726.jpg' 'https://gs.ifeng.com/'; } &
{ fetch_img xiaojun.jpg 'https://x0.ifengimg.com/ucms/2021_12/A9701201F825608C340C1A4ADB53EE2C800E4CC2_size26_w399_h300.jpg' 'https://gs.ifeng.com/'; } &
{ fetch_img prison.png 'https://x0.ifengimg.com/res/2020/00FA35A57C5BCEA0FCF26ED1F30212BB63582367_size632_w833_h566.png' 'https://www.ifeng.com/'; } &
{ fetch_img piano.png 'https://media.bjnews.com.cn/image/2025/06/14/5598003721448532979.png' 'https://www.bjnews.com.cn/'; } &
{ fetch_img uniform.jpg 'https://k.sinaimg.cn/n/sinakd20230414s/491/w640h651/20230414/201f-28aa401a5f07d8f2d41300d708c715ab.jpg/w700d1q75cms.jpg?by=cms_fixed_width' 'https://www.sina.com.cn/'; } &
{ fetch_img bookstore.jpg 'https://i2.chinanews.com/simg/hnhd/2023/11/29/64/8714948600698490096.jpg' 'https://www.chinanews.com.cn/'; } &
{ fetch_img sanmao1.jpg 'https://n.sinaimg.cn/sinakd20116/203/w1024h779/20221021/ab33-900b63933a7af7b4041b0a5eb3df0609.jpg' 'https://www.sina.com.cn/'; } &
{ fetch_img sanmao2.jpg 'https://media.bjnews.com.cn/cover/2025/06/14/5597918564158873775.jpg' 'https://www.bjnews.com.cn/'; } &
{ fetch_img sanmao_piano.jpg 'https://media.bjnews.com.cn/cover/2025/06/14/5597918565152924553.jpg' 'https://www.bjnews.com.cn/'; } &
{ fetch_img taiwan_press.jpg 'https://i2.chinanews.com/simg/hnhd/2023/11/29/68/8316959810859968144.jpg' 'https://www.chinanews.com.cn/'; } &
{ fetch_img taiwan_group.jpg 'https://g.udn.com.tw/upfiles/B_ME/melyang2008/PSN_PHOTO/416/f_7741416_1.jpg' 'https://udn.com/'; } &
{ fetch_img liangan.jpg 'https://i2.chinanews.com/simg/hnhd/2023/11/29/95/15747710494210093215.jpg' 'https://www.chinanews.com.cn/'; } &
wait || true

if [[ ! -f src/portrait.jpg ]]; then fetch_img portrait.jpg 'https://www.krzzjn.com/uploadfile/2020/0703/20200703032538391.jpg' 'https://www.krzzjn.com/' || true; fi
if [[ ! -f src/portrait.jpg ]]; then fetch_img portrait.jpg 'https://bkimg.cdn.bcebos.com/pic/500fd9f9d72a6059252defb3d468239b033b5bb50c5f' 'https://baike.baidu.com/' || true; fi
[[ -f src/portrait.jpg ]] || { echo 'No verified Wang Luobin image'; exit 2; }
fallback(){ [[ -f "src/$1" ]] || cp "src/$2" "src/$1"; }
fallback manuscript.jpg portrait.jpg; fallback early.jpg portrait.jpg; fallback lanzhou.jpg early.jpg; fallback xiaojun.jpg lanzhou.jpg; fallback prison.png portrait.jpg; fallback piano.png portrait.jpg; fallback uniform.jpg portrait.jpg; fallback bookstore.jpg portrait.jpg; fallback sanmao1.jpg portrait.jpg; fallback sanmao2.jpg sanmao1.jpg; fallback sanmao_piano.jpg sanmao1.jpg; fallback taiwan_press.jpg portrait.jpg; fallback taiwan_group.jpg taiwan_press.jpg; fallback liangan.jpg manuscript.jpg

make_frame(){ i="$1"; s="$2"; ffmpeg -hide_banner -loglevel error -y -i "src/$s" -filter_complex "[0:v]split=2[bg][fg];[bg]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,boxblur=14:2,eq=brightness=-0.18[bg2];[fg]scale=680:1160:force_original_aspect_ratio=decrease[fg2];[bg2][fg2]overlay=(W-w)/2:(H-h)/2,format=yuv420p[v]" -map '[v]' -frames:v 1 "frames/$i.jpg"; }
imgs=(portrait.jpg manuscript.jpg early.jpg lanzhou.jpg xiaojun.jpg xiaojun.jpg early.jpg lanzhou.jpg manuscript.jpg early.jpg manuscript.jpg prison.png prison.png piano.png uniform.jpg piano.png piano.png bookstore.jpg sanmao1.jpg sanmao2.jpg sanmao_piano.jpg taiwan_press.jpg taiwan_group.jpg liangan.jpg portrait.jpg piano.png manuscript.jpg portrait.jpg)
for n in $(seq 1 28); do i=$(printf '%02d' "$n"); make_frame "$i" "${imgs[$((n-1))]}"; done

durs=(14.3 15.0 28.5 14.2 11.8 20.6 22.6 21.9 29.2 33.4 42.6 33.0 45.7 29.1 18.5 32.8 31.1 24.1 25.3 29.3 20.8 14.2 13.6 15.7 19.4 24.0 18.5 23.8)
: > slides.txt
for n in $(seq 1 28); do i=$(printf '%02d' "$n"); echo "file '$PWD/frames/$i.jpg'" >> slides.txt; echo "duration ${durs[$((n-1))]}" >> slides.txt; done
echo "file '$PWD/frames/28.jpg'" >> slides.txt
ffmpeg -hide_banner -loglevel error -y -f concat -safe 0 -i slides.txt -vf 'fps=30,format=yuv420p' -c:v libx264 -preset ultrafast -crf 24 -movflags +faststart out/wangluobin_video_only.mp4
ffprobe -v error -show_entries format=duration,size -of default=nw=1 out/wangluobin_video_only.mp4
