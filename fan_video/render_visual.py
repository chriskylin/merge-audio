#!/usr/bin/env python3
import pathlib, subprocess
R=pathlib.Path(__file__).resolve().parent
A=R/'assets'; S=R/'segments'; O=R/'output'
for d in (A,S,O): d.mkdir(parents=True,exist_ok=True)
RAW='''P01|https://www.news.cn/sports/20240804/a0a83fd7ffa449e7971192968a069750/7f310cf279264a55bc3194fec95d09cc.jpg|https://www.news.cn/sports/20240804/a0a83fd7ffa449e7971192968a069750/c.html
P02|https://www.news.cn/sports/20240804/a0a83fd7ffa449e7971192968a069750/cc8661f14eac49fbba31bcd90ffadaff.jpg|https://www.news.cn/sports/20240804/a0a83fd7ffa449e7971192968a069750/c.html
P03|https://www.news.cn/sports/20240804/a0a83fd7ffa449e7971192968a069750/dd46a20ed1e4424cad1c94abe2b652fd.jpg|https://www.news.cn/sports/20240804/a0a83fd7ffa449e7971192968a069750/c.html
P04|https://www.news.cn/sports/20240804/a0a83fd7ffa449e7971192968a069750/BS1rGT3JfvgWRU82.jpg|https://www.news.cn/sports/20240804/a0a83fd7ffa449e7971192968a069750/c.html
P05|https://www.news.cn/sports/20240804/a0a83fd7ffa449e7971192968a069750/SBsaqOlBMzkN0QgR.jpg|https://www.news.cn/sports/20240804/a0a83fd7ffa449e7971192968a069750/c.html
P06|https://www.news.cn/sports/20240804/a0a83fd7ffa449e7971192968a069750/FPWyLfQoq4pL28eR.jpg|https://www.news.cn/sports/20240804/a0a83fd7ffa449e7971192968a069750/c.html
P07|https://www.news.cn/sports/20240804/a0a83fd7ffa449e7971192968a069750/QKKyXHfOr4sCW5GP.jpg|https://www.news.cn/sports/20240804/a0a83fd7ffa449e7971192968a069750/c.html
P08|https://www.imtcme.edu.cn/__local/7/D9/A5/53EFFD9FC0E42017FE8F9B4F4E4_266C676B_1ED74.jpg|https://www.imtcme.edu.cn/tyjxb/info/1062/2445.htm
W01|https://oss.cyzone.cn/2025/0108/cf68697d577bbe6152c1744018c34c09.jpg?x-oss-process=image%2Fresize%2Cw_1280%2Cm_mfit%2Fformat%2Cjpg%2Fquality%2Cq_95|https://m.cyzone.cn/article/787025
W02|https://www.sportsroad.hk/wp-content/uploads/2024/12/Table-Tennis_20241227_Fan-Zhen-Dong_WB_Cover.png|https://www.sportsroad.hk/archives/532796/
S01|https://fcs-tischtennis.de/wp-content/uploads/2025/09/FCS-TT_Mannschaft1_2025_Fan_Zhendong_B01.jpg|https://fcs-tischtennis.de/
S02|https://img2.chinadaily.com.cn/images/202508/28/68afd6c1a3108622d6407146.jpeg|https://www.chinadaily.com.cn/a/202508/28/WS68afd6c1a3108622abc9d9f4.html
S03|https://p5.img.cctvpic.com/photoworkspace/2025/09/07/2025090712555827703.jpg|https://tv.cctv.com/2025/09/07/VIDEklR3RlMt4FZIwMtofeDg250907.shtml
S04|https://www.news.cn/20260531/f9e96fb270b442d2a0901df021a78e83/202605314989287a2efc4d28bae2956f300cee59_69bbecb51d7a48aa896d52303d3c2456.JPG|https://www.news.cn/20260531/f9e96fb270b442d2a0901df021a78e83/c.html
S05|https://p.statickksmg.com/cont/2026/01/05/image_1767597692_rLmM1QQz_w1280.jpg|https://www.kankanews.com/detail/6Y2DWOjzGw1
S06|https://q0.itc.cn/q_70/images03/20260105/2ab0406f11534dfc8a9d5da9d063e714.jpeg|https://www.sohu.com/a/972670671_120546417
S07|https://dw-media.wenweipo.com/dams/wwpproduct/image/202605/31/6a1c22c6e4b08c07fcf4f5f71.jpg|https://www.wenweipo.com/a/202605/31/AP6a1c2ab8e4b0b49ad1bd7fd9.html
S08|https://storage.ghost.io/c/be/50/be50f981-86d0-4af6-9f59-c38dab12ada5/content/images/2026/06/Spieler-der-Saison_Fan-Zhendong.png|https://www.ttbl.de/news/post/6a2950ca19da830001e211e8
D01|https://www.borussia-duesseldorf.com/fileadmin/user_upload/borussia_duesseldorf_timo_boll_fan_zhendong_andreas_preuss_16.3.2026.jpg|https://www.borussia-duesseldorf.com/profis/news/personalie-borussia-verpflichtet-olympiasieger-fan-zhendong
D02|https://xity.de/wp-content/uploads/2026/08/260822_JF_0725.jpg|https://xity.de/lokal-news/nordrhein-westfalen/duesseldorf/borussia-duesseldorf-feiert-sieg-bei-fan-zhendong-premiere/
D03|https://www.d-sports.de/fileadmin/_processed_/5/0/csm_zhendong_1_2f787c3a64.jpg|https://www.d-sports.de/
C01|https://upload.wikimedia.org/wikipedia/commons/e/e4/Fan_Zhendong_ACTTC2016_7.jpeg|https://commons.wikimedia.org/wiki/File:Fan_Zhendong_ACTTC2016_7.jpeg'''
AS={}
for line in RAW.splitlines():
    k,u,r=line.split('|',2); AS[k]=(u,r)
ALT={
'P01':['https://english.news.cn/20240805/b70a5b1a21d443a5b7e2916640b77492/20240805b70a5b1a21d443a5b7e2916640b77492_XxjpbeE007001_20240805_CBMFN0A003.JPG'],
'P05':['https://english.news.cn/20240805/b70a5b1a21d443a5b7e2916640b77492/20240805b70a5b1a21d443a5b7e2916640b77492_665707597dab4a259435e62c1b2bbf1e.JPG'],
'S03':['https://www.news.cn/sports/20250901/edabe1ffb9714a8bb8dde289836c3bd9/vNDpjTtNPfnI8fj4.jpeg'],
'D01':['https://www.duesseldorfer-anzeiger.de/imgs/51/2/6/1/5/3/1/0/7/7/tok_f06b31ec2bc82e94aab3a07283156efc/w1200_h1200_x1250_y857_borussia_duesseldorf_timo_boll_fan_zhendong_andreas_preuss_16.3.2026-40d054a403e834e0.jpg'],
'D03':['https://www1.wdr.de/sport/mehr-sport/fan-zhendong-102~_v-gseagaleriexl.jpg','https://cdnmedia.webthethao.vn/thumb/720-405/uploads/2026-03-17/fzd-173.jpg']}
SEQ='P01:7.550;P02:5.460;P03:8.240;P04:8.410;P05:9.370;P06:9.170;P07:6.810;P08:9.970;P01:8.700;P02:7.225;P03:6.045;P04:8.300;P05:6.990;W01:10.120;W02:8.130;P07:7.390;S01:8.650;S02:7.700;P08:9.885;W01:7.245;W02:7.650;P03:7.415;C01:9.135;W01:9.540;P04:7.310;W01:8.805;W02:8.485;P03:9.070;C01:8.660;S02:7.230;S03:6.240;S01:10.365;S04:8.465;S03:7.240;S02:8.030;S04:8.160;S02:8.770;S08:9.015;S05:7.235;S06:6.740;S07:7.830;S04:6.840;S03:9.720;S04:9.750;S02:8.210;S07:5.920;S03:5.370;S05:7.580;S03:6.770;D01:8.990;D01:6.310;D02:8.600;D03:8.780;D01:9.310;D02:7.725;D01:8.505;D01:7.830;D02:7.720;D03:6.650;S07:9.860;S06:8.300;D02:7.000;D03:8.895;S06:8.515;S04:8.800;D01:9.250;D02:8.060;S05:7.070;S06:8.190;P07:9.930;D01:7.380;S04:8.520;P08:9.325;S05:8.055;P07:8.860;D02:7.450;S04:7.400;P08:7.960;D01:7.980;P01:9.430;C01:7.590;P07:6.000;D02:10.345'
SH=[(x.split(':')[0],float(x.split(':')[1])) for x in SEQ.split(';')]
UA='Mozilla/5.0 Chrome/131 Safari/537.36'
def ok(p):
    if not p.exists() or p.stat().st_size<5000:return False
    q=subprocess.run(['ffprobe','-v','error','-select_streams','v:0','-show_entries','stream=width,height','-of','csv=p=0:s=x',str(p)],capture_output=True,text=True)
    return q.returncode==0 and 'x' in q.stdout
def ext(p):
    b=p.read_bytes()[:16]
    if b.startswith(b'\x89PNG'):return '.png'
    if b.startswith(b'RIFF'):return '.webp'
    return '.jpg'
def dl(k):
    u,r=AS[k]; tmp=A/(k+'.tmp')
    for url in [u]+ALT.get(k,[]):
        if tmp.exists():tmp.unlink()
        cmd=['curl','-L','--fail','--retry','3','--connect-timeout','15','--max-time','90','-A',UA]
        if r:cmd+=['-e',r]
        cmd+=['-o',str(tmp),url]
        if subprocess.run(cmd).returncode==0 and ok(tmp):
            f=A/(k+ext(tmp));tmp.replace(f);print('OK',k,f.stat().st_size,flush=True);return f
    if tmp.exists():tmp.unlink()
    return None
P={'C01':dl('C01')}
if not P['C01']:raise SystemExit('C01 fallback failed')
for k in AS:
    if k!='C01':P[k]=dl(k) or P['C01']
VF='[0:v]split=2[bg][fg];[bg]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,boxblur=18:2,eq=brightness=-0.24:saturation=0.78[bg2];[fg]scale=1000:1780:force_original_aspect_ratio=decrease[fg2];[bg2][fg2]overlay=(W-w)/2:(H-h)/2,format=yuv420p[v]'
l=[]
for i,(k,d) in enumerate(SH,1):
    o=S/f'shot_{i:03d}.mp4'
    subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-loop','1','-framerate','25','-t',f'{d:.3f}','-i',str(P[k]),'-filter_complex',VF,'-map','[v]','-r','25','-an','-c:v','libx264','-preset','veryfast','-crf','22','-pix_fmt','yuv420p',str(o)],check=True)
    l.append("file '"+o.as_posix()+"'\n")
(R/'concat.txt').write_text(''.join(l))
out=O/'fan_visual.mp4'
subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-f','concat','-safe','0','-i',str(R/'concat.txt'),'-c','copy','-movflags','+faststart',str(out)],check=True)
subprocess.run(['ffprobe','-v','error','-show_entries','format=duration,size','-show_entries','stream=width,height','-of','json',str(out)],check=True)
print('FINAL',out,out.stat().st_size)
