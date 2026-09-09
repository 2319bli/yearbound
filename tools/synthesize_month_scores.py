# Original temporary monthly score sketches; never overwrites supplied music.
import wave, math, array, pathlib
R=22050
out=pathlib.Path(__file__).resolve().parents[1]/'audio'
specs=[('july',132,[72,76,79,83,79,76,74,79],[48,53,55,60]),('august',94,[69,72,76,79,77,72,71,64],[45,41,48,40]),('september',92,[67,71,74,78,76,74,69,66],[43,47,40,45]),('november',78,[62,65,69,72,70,65,64,57],[38,34,41,36]),('december',76,[79,83,86,90,88,83,81,78],[55,52,48,50]),('february',88,[71,74,78,81,79,76,74,69],[47,43,50,45]),('april',114,[74,78,81,85,83,81,76,73],[50,55,52,57]),('may',126,[76,79,83,86,88,83,81,79],[48,55,53,60])]
for name,bpm,notes,bass in specs:
 beat=60/bpm; duration=beat*64; samples=array.array('f',[0])*int(duration*R)
 def note(midi,start,length,gain,kind):
  freq=440*2**((midi-69)/12); first=int(start*R); count=min(int(length*R),len(samples)-first)
  for i in range(count):
   t=i/R; env=min(1,t/.022)*min(1,(length-t)/.15)
   if kind=='bell': env*=math.exp(-t*3); v=math.sin(math.tau*freq*t)+.24*math.sin(math.tau*freq*2*t)
   elif kind=='pad':v=math.sin(math.tau*freq*t)+.18*math.sin(math.tau*freq*2.003*t)
   else:env*=math.exp(-t*2);v=math.sin(math.tau*freq*t)
   samples[first+i]+=v*env*gain
 for bar in range(16):
  b=bass[(bar//2)%4]
  for n in [b+12,b+19,b+24]:note(n,bar*4*beat,4*beat,.035,'pad')
  for j in range(4):
   note(b+(12 if j%2 else 0),(bar*4+j)*beat,beat*.8,.08,'bass')
   idx=(bar*(2 if name in ['november','december'] else 3)+j+(2 if bar>=8 else 0))%8
   note(notes[idx],(bar*4+j+.25)*beat,beat*1.1,.085,'bell')
  if name in ['july','april','may']:
   for j in range(8):note(91 if name!='november' else 43,(bar*4+j*.5)*beat,.09,.035,'bell')
 pcm=array.array('h',(int(max(-.95,min(.95,x))*28000) for x in samples))
 with wave.open(str(out/(name+'.wav')),'wb') as w:w.setnchannels(1);w.setsampwidth(2);w.setframerate(R);w.writeframes(pcm.tobytes())
 print(name,len(pcm)/R)
