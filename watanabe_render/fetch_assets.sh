#!/usr/bin/env bash
set -euo pipefail
mkdir -p assets
UA='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/152 Safari/537.36'
get(){ local n="$1" u="$2" r="$3"; echo "$n"; curl -L --fail --retry 3 --connect-timeout 20 --max-time 90 -A "$UA" -e "$r" -o "assets/$n" "$u"; }
get book.jpg 'https://auctions.c.yimg.jp/images.auctions.yahoo.co.jp/image/dr000/auc0412/users/fd51423cbaca193f6dbc12ac42269eeff847ec69/i-img1200x900-1703894173tvzbrk181627.jpg' 'https://auctions.yahoo.co.jp/'
get young.jpg 'https://watanabe-museum.com/img/ryakureki.jpg' 'https://watanabe-museum.com/biography.html'
get portrait.jpg 'https://b-bunshun.ismcdn.jp/mwimgs/4/3/1500wm/img_439d91a9ec31e1e52e218b9e0312fe2366916.jpg' 'https://books.bunshun.jp/articles/-/3046'
get writing.jpg 'https://fujinkoronmw.ismcdn.jp/mwimgs/3/3/-/img_332c0851435761e8c04f7329ed4224f8134281.jpg' 'https://fujinkoron.jp/articles/photo/12103'
get late.jpg 'https://fujinkoronmw.ismcdn.jp/mwimgs/4/d/-/img_4dcb6e3079c30b7c17c8ce2d1ef120b5897328.jpg' 'https://fujinkoron.jp/articles/photo/12103'
get late_event.jpg 'https://fujinkoronmw.ismcdn.jp/mwimgs/7/4/-/img_74de8704f3c8a4b4db5e3997741eb471288879.jpg' 'https://fujinkoron.jp/articles/photo/12103'
get late_china.jpg 'https://ent.chinadaily.com.cn/img/attachement/jpg/site1/20140506/0023ae72898c14d27beb18.jpg' 'https://ent.chinadaily.com.cn/2014-05/06/content_17486327.htm'
get late_sohu.jpg 'https://5b0988e595225.cdn.sohucs.com/q_70%2Cc_zoom%2Cw_640/images/20191024/c998c0169ed34c3a84946d80f10dd27b.jpeg' 'https://www.sohu.com/'
get med_hospital.jpg 'https://web.sapmed.ac.jp/kikaku/65th/images/history/195042.jpg' 'https://web.sapmed.ac.jp/kikaku/65th/history.html'
get med_campus.jpg 'https://web.sapmed.ac.jp/kikaku/65th/images/history/1956.jpg' 'https://web.sapmed.ac.jp/kikaku/65th/history.html'
get light_shadow.jpg 'https://b-bunshun.ismcdn.jp/mwimgs/f/2/350/img_f26fddef99d35607846a50b02178ee13867528.jpg' 'https://books.bunshun.jp/ud/book/num/9784167145262'
get lost_paradise.jpg 'https://media.eiga.com/images/movie/14158/photo/ce8ecbffa4491131.jpg' 'https://eiga.com/movie/14158/'
get bts.jpg 'https://res.cloudinary.com/fridaydigital/image/private/t_article_image/wpmedia/2023/07/bc8966f922209da7b864289f283763e9.jpg' 'https://friday.kodansha.co.jp/'
get museum.jpg 'https://sapporotravel.s3-ap-northeast-1.amazonaws.com/st/ph/img/c066-003.jpg' 'https://www.sapporo.travel/'
file assets/*
ls -lh assets
