from pathlib import Path
import subprocess
R=Path(__file__).resolve().parent; A=R/'qassets'; S=R/'qsegments'; O=R/'output'
for d in (A,S,O): d.mkdir(parents=True,exist_ok=True)
URL={
'C':'https://upload.wikimedia.org/wikipedia/commons/e/e4/Fan_Zhendong_ACTTC2016_7.jpeg',
'P1':'https://english.news.cn/20240805/b70a5b1a21d443a5b7e2916640b77492/20240805b70a5b1a21d443a5b7e2916640b77492_XxjpbeE007001_20240805_CBMFN0A003.JPG',
'P2':'https://english.news.cn/20240805/b70a5b1a21d443a5b7e2916640b77492/20240805b70a5b1a21d443a5b7e2916640b77492_665707597dab4a259435e62c1b2bbf1e.JPG',
'P3':'https://www.imtcme.edu.cn/__local/7/D9/A5/53EFFD9FC0E42017FE8F9B4F4E4_266C676B_1ED74.jpg',
'W1':'https://www.sportsroad.hk/wp-content/uploads/2024/12/Table-Tennis_20241227_Fan-Zhen-Dong_WB_Cover.png',
'W2':'https://oss.cyzone.cn/2025/0108/cf68697d577bbe6152c1744018c34c09.jpg?x-oss-process=image%2Fresize%2Cw_1280%2Cm_mfit%2Fformat%2Cjpg%2Fquality%2Cq_95',
'S1':'https://fcs-tischtennis.de/wp-content/uploads/2025/09/FCS-TT_Mannschaft1_2025_Fan_Zhendong_B01.jpg',
'S2':'https://www.news.cn/sports/20250901/edabe1ffb9714a8bb8dde289836c3bd9/vNDpjTtNPfnI8fj4.jpeg',
'S3':'https://p5.img.cctvpic.com/photoworkspace/2025/09/07/2025090712555827703.jpg',
'S4':'https://storage.ghost.io/c/be/50/be50f981-86d0-4af6-9f59-c38dab12ada5/content/images/2026/06/Spieler-der-Saison_Fan-Zhendong.png',
'D1':'https://www.borussia-duesseldorf.com/fileadmin/user_upload/borussia_duesseldorf_timo_boll_fan_zhendong_andreas_preuss_16.3.2026.jpg',
'D2':'https://xity.de/wp-content/uploads/2026/08/260822_JF_0725.jpg',
'D3':'https://www1.wdr.de/sport/mehr-sport/fan-zhendong-102~_v-gseagaleriexl.jpg'}
MAP={'P01':'P1','P02':'P1','P03':'P2','P04':'P1','P05':'P2','P06':'P1','P07':'P2','P08':'P3','W01':'W2','W02':'W1','S01':'S1','S02':'S1','S03':'S3','S04':'S2','S05':'S4','S06':'S4','S07':'S2','S08':'S4','D01':'D1','D02':'D2','D03':'D3','C01':'C'}
SH=[('P01',7.55),('P02',5.46),('P03',8.24),('P04',8.41),('P05',9.37),('P06',9.17),('P07',6.81),('P08',9.97),('P01',8.7),('P02',7.225),('P03',6.045),('P04',8.3),('P05',6.99),('W01',10.12),('W02',8.13),('P07',7.39),('S01',8.65),('S02',7.7),('P08',9.885),('W01',7.245),('W02',7.65),('P03',7.415),('C01',9.135),('W01',9.54),('P04',7.31),('W01',8.805),('W02',8.485),('P03',9.07),('C01',8.66),('S02',7.23),('S03',6.24),('S01',10.365),('S04',8.465),('S03',7.24),('S02',8.03),('S04',8.16),('S02',8.77),('S08',9.015),('S05',7.235),('S06',6.74),('S07',7.83),('S04',6.84),('S03',9.72),('S04',9.75),('S02',8.21),('S07',5.92),('S03',5.37),('S05',7.58),('S03',6.77),('D01',8.99),('D01',6.31),('D02',8.6),('D03',8.78),('D01',9.31),('D02',7.725),('D01',8.505),('D01',7.83),('D02',7.72),('D03',6.65),('S07',9.86),('S06',8.3),('D02',7.0),('D03',8.895),('S06',8.515),('S04',8.8),('D01',9.25),('D02',8.06),('S05',7.07),('S06',8.19),('P07',9.93),('D01',7.38),('S04',8.52),('P08',9.325),('S05',8.055),('P07',8.86),('D02',7.45),('S04',7.4),('P08',7.96),('D01',7.98),('P01',9.43),('C01',7.59),('P07',6.0),('D02',10.345)]

def good(p):
 q=subprocess.run(['ffprobe','-v','error','-select_streams','v:0','-show_entries','stream=width,height','-of','csv=p=0:s=x',str(p)],capture_output=True,text=True);return p.exists() and p.stat().st_size>5000 and q.returncode==0

def grab(k):
 p=A/(k+'.img'); subprocess.run(['curl','-L','--fail','--retry','1','--connect-timeout','8','--max-time','20','-A','Mozilla/5.0 Chrome/131','-o',str(p),URL[k]]); return p if good(p) else None
P={}; P['C']=grab('C')
if not P['C']: raise SystemExit('fallback failed')
for k in URL:
 if k!='C': P[k]=grab(k) or P['C']
VF='scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=0x101010,format=yuv420p'
cat=[]
for i,(aid,dur) in enumerate(SH,1):
 out=S/f'{i:03d}.mp4'; img=P[MAP[aid]]
 subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-loop','1','-framerate','2','-t',str(dur),'-i',str(img),'-vf',VF,'-r','2','-an','-c:v','libx264','-preset','ultrafast','-crf','20','-pix_fmt','yuv420p',str(out)],check=True)
 cat.append("file '"+out.as_posix()+"'\n")
(R/'qconcat.txt').write_text(''.join(cat))
out=O/'fan_visual.mp4'
subprocess.run(['ffmpeg','-hide_banner','-loglevel','error','-y','-f','concat','-safe','0','-i',str(R/'qconcat.txt'),'-c','copy','-movflags','+faststart',str(out)],check=True)
print('FINAL',out,out.stat().st_size)
