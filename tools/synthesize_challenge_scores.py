#!/usr/bin/env python3
"""132 distinct original placeholder loops. Requires NumPy for offline synthesis."""
from pathlib import Path
import json, wave, math
import numpy as np

ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'audio/challenges';OUT.mkdir(exist_ok=True)
RATE=22050
MONTHS=[6,7,8,9,10,11,12,1,2,3,4,5]
MODES=[[0,2,4,7,9],[0,2,4,6,7,9,11],[0,2,3,7,10],[0,2,3,5,7,10],[0,1,3,6,7,10],[0,2,3,5,7,8,10],[0,2,4,7,11],[0,2,3,6,7,9],[0,2,3,5,7,9],[0,2,4,5,7,9],[0,2,4,7,9,11],[0,2,4,5,7,9,11]]
for entry in json.loads((ROOT/'content/monthly_challenges.json').read_text()):
    mi=MONTHS.index(entry['month']);k=entry['number'];mode=MODES[mi]
    bpm=[124,146,132,120,154,98,118,140,126,150,136,142][mi]+(k%4)*3
    beat=60/bpm;duration=64*beat;mix=np.zeros(int(duration*RATE),dtype=np.float64)
    tonic=45+(mi*5+k*2)%12
    def note(midi,start,length,gain,voice):
        first=int(start*RATE);count=min(int(length*RATE),len(mix)-first)
        if count<=0:return
        t=np.arange(count)/RATE;f=440*2**((midi-69)/12)
        envelope=np.minimum(1,t/.014)*np.minimum(1,(length-t)/.09)
        if voice==0:envelope*=np.exp(-t*(2.4+mi%3));v=np.sin(math.tau*f*t)+.2*np.sin(math.tau*f*2*t)
        elif voice==1:v=np.sin(math.tau*f*t)+.14*np.sin(math.tau*f*2.002*t)
        else:envelope*=np.exp(-t*7);v=np.sin(math.tau*f*t)*.8+.2*np.sin(math.tau*f*.5*t)
        mix[first:first+count]+=v*envelope*gain
    for bar in range(16):
        root=tonic+mode[(bar//2+k)%len(mode)]
        for offset in [0,7,12]:note(root+offset,bar*4*beat,beat*3.9,.028,1)
        for step in range(8):
            degree=(bar*(k%3+1)+step*(mi%3+1)+k+step//3)%len(mode)
            pitch=tonic+24+mode[degree]+(12 if (bar+step+k)%11==0 else 0)
            if (step+bar+k)%7!=0:note(pitch,(bar*4+step*.5)*beat,beat*(.65+.1*(k%3)),.077,0)
            if step%2==0:note(root-12,(bar*4+step*.5)*beat,beat*.7,.095,2)
            if mi not in [5,6] and step%2:note(tonic+36+(step+k)%12,(bar*4+step*.5)*beat,.06,.028,2)
    # Starts and ends at zero. No non-looping reverb tail or sample dependency.
    fade=min(int(.035*RATE),len(mix)//2)
    mix[:fade]*=np.linspace(0,1,fade);mix[-fade:]*=np.linspace(1,0,fade)
    pcm=(np.clip(mix,-.9,.9)*30000).astype('<i2')
    with wave.open(str(OUT/(entry['id']+'.wav')),'wb') as f:
        f.setnchannels(1);f.setsampwidth(2);f.setframerate(RATE);f.writeframes(pcm.tobytes())
print('Synthesized 132 separate original challenge sketches.')
