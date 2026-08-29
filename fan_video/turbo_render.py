from pathlib import Path
import re
p=Path(__file__).with_name('render_visual.py')
code=p.read_text(encoding='utf-8')
fast="VF='[0:v]scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2:color=0x101010,format=yuv420p[v]'\nl=[]"
code=re.sub(r"VF='.*?'\nl=\[\]",fast,code,count=1)
code=code.replace("'-preset','veryfast','-crf','22'","'-preset','ultrafast','-crf','20'")
code=code.replace("'-framerate','25'","'-framerate','5'").replace("'-r','25'","'-r','5'")
exec(compile(code,str(p),'exec'))
