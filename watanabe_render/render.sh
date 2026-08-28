#!/usr/bin/env bash
set -euo pipefail

mkdir -p assets scenes out
UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/152 Safari/537.36'

download_img() {
  local name="$1" url="$2" referer="$3"
  echo "Downloading $name"
  curl -L --fail --retry 3 --retry-delay 2 --connect-timeout 20 --max-time 90 \
    -A "$UA" -e "$referer" -o "assets/$name" "$url" || rm -f "assets/$name"
}

download_img book.jpg 'https://auctions.c.yimg.jp/images.auctions.yahoo.co.jp/image/dr000/auc0412/users/fd51423cbaca193f6dbc12ac42269eeff847ec69/i-img1200x900-1703894173tvzbrk181627.jpg' 'https://auctions.yahoo.co.jp/'
download_img young.jpg 'https://watanabe-museum.com/img/ryakureki.jpg' 'https://watanabe-museum.com/biography.html'
download_img portrait.jpg 'https://b-bunshun.ismcdn.jp/mwimgs/4/3/1500wm/img_439d91a9ec31e1e52e218b9e0312fe2366916.jpg' 'https://books.bunshun.jp/articles/-/3046'
download_img writing.jpg 'https://fujinkoronmw.ismcdn.jp/mwimgs/3/3/-/img_332c0851435761e8c04f7329ed4224f8134281.jpg' 'https://fujinkoron.jp/articles/photo/12103'
download_img late.jpg 'https://fujinkoronmw.ismcdn.jp/mwimgs/4/d/-/img_4dcb6e3079c30b7c17c8ce2d1ef120b5897328.jpg' 'https://fujinkoron.jp/articles/photo/12103'
download_img late_event.jpg 'https://fujinkoronmw.ismcdn.jp/mwimgs/7/4/-/img_74de8704f3c8a4b4db5e3997741eb471288879.jpg' 'https://fujinkoron.jp/articles/photo/12103'
download_img late_china.jpg 'https://ent.chinadaily.com.cn/img/attachement/jpg/site1/20140506/0023ae72898c14d27beb18.jpg' 'https://ent.chinadaily.com.cn/2014-05/06/content_17486327.htm'
download_img late_sohu.jpg 'https://5b0988e595225.cdn.sohucs.com/q_70%2Cc_zoom%2Cw_640/images/20191024/c998c0169ed34c3a84946d80f10dd27b.jpeg' 'https://www.sohu.com/'
download_img med_hospital.jpg 'https://web.sapmed.ac.jp/kikaku/65th/images/history/195042.jpg' 'https://web.sapmed.ac.jp/kikaku/65th/history.html'
download_img med_campus.jpg 'https://web.sapmed.ac.jp/kikaku/65th/images/history/1956.jpg' 'https://web.sapmed.ac.jp/kikaku/65th/history.html'
download_img light_shadow.jpg 'https://b-bunshun.ismcdn.jp/mwimgs/f/2/350/img_f26fddef99d35607846a50b02178ee13867528.jpg' 'https://books.bunshun.jp/ud/book/num/9784167145262'
download_img lost_paradise.jpg 'https://media.eiga.com/images/movie/14158/photo/ce8ecbffa4491131.jpg' 'https://eiga.com/movie/14158/'
download_img bts.jpg 'https://res.cloudinary.com/fridaydigital/image/private/t_article_image/wpmedia/2023/07/bc8966f922209da7b864289f283763e9.jpg' 'https://friday.kodansha.co.jp/'
download_img museum.jpg 'https://sapporotravel.s3-ap-northeast-1.amazonaws.com/st/ph/img/c066-003.jpg' 'https://www.sapporo.travel/'

FALLBACK=''
for f in young.jpg portrait.jpg writing.jpg late.jpg late_china.jpg late_sohu.jpg museum.jpg; do [[ -s "assets/$f" ]] && { FALLBACK="$f"; break; }; done
[[ -n "$FALLBACK" ]] || { echo 'No images' >&2; exit 2; }
pick(){ [[ -s "assets/$1" ]] && echo "$1" || echo "$FALLBACK"; }

cat > scenes/map.tsv <<'EOF'
14.43|book.jpg
29.10|book.jpg
9.71|young.jpg
44.28|med_campus.jpg
21.59|light_shadow.jpg
33.31|med_hospital.jpg
22.12|portrait.jpg
6.91|portrait.jpg
26.05|lost_paradise.jpg
32.09|late.jpg
24.80|book.jpg
33.66|late.jpg
28.54|portrait.jpg
5.90|late_china.jpg
26.84|book.jpg
24.30|late_china.jpg
21.52|late.jpg
34.57|writing.jpg
29.93|portrait.jpg
22.64|book.jpg
29.74|late_event.jpg
37.55|writing.jpg
9.44|late.jpg
32.85|writing.jpg
6.32|young.jpg
22.52|med_hospital.jpg
22.63|writing.jpg
18.49|late_china.jpg
18.29|late_sohu.jpg
12.74|young.jpg
22.14|museum.jpg
EOF

idx=1
while IFS='|' read -r dur requested; do
  asset="$(pick "$requested")"; printf -v num '%02d' "$idx"
  echo "Render $num ${dur}s $asset"
  # 2 fps is enough for a static-photo intermediate; final 25 fps is produced locally with subtitles/audio.
  ffmpeg -nostdin -hide_banner -loglevel error -y -loop 1 -framerate 2 -i "assets/$asset" -t "$dur" \
    -filter_complex "[0:v]scale=720:1280:force_original_aspect_ratio=increase,crop=720:1280,boxblur=14:2[bg];[0:v]scale=680:1180:force_original_aspect_ratio=decrease[fg];[bg][fg]overlay=(W-w)/2:(H-h)/2,format=yuv420p" \
    -r 2 -an -c:v libx264 -preset ultrafast -crf 20 "scenes/scene_${num}.mp4"
  idx=$((idx+1))
done < scenes/map.tsv

: > scenes/concat.txt
for f in scenes/scene_*.mp4; do echo "file '$PWD/$f'" >> scenes/concat.txt; done
ffmpeg -nostdin -hide_banner -loglevel error -y -f concat -safe 0 -i scenes/concat.txt -c copy out/watanabe_silent.mp4
ffprobe -v error -show_entries format=duration -of default=nw=1:nk=1 out/watanabe_silent.mp4
ls -lh out/watanabe_silent.mp4
