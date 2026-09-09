"""Author explicit, distinct route recipes, then bake ordinary editable stage JSON."""
from pathlib import Path
import json,copy,subprocess,math
P=Path(__file__).resolve().parents[1]
def baseline(day):return json.loads(subprocess.check_output(['git','show',f'v0.11.0:content/stages/{day}.json'],cwd=P))
# Each room is a deliberately chosen elevation sequence, rather than a palette swap.
# Elevations are absolute block rows above the original meadow floor.
import argparse
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--write',action='store_true',help='Replace the baked campaign stages from the v0.11.0 baseline and current recipes.')
if not parser.parse_args().write: parser.error('Pass --write to regenerate the baked stage JSON. This replaces later hand edits.')
ROUTES={day:('|'.join(r['rooms']),r['elevations'],r['material'],r['landing_blocks'],r['gap_blocks']) for day,r in json.loads((P/'content/challenge_recipes.json').read_text()).items()}

def rect_hits(a,b,pad=0):return a['x']<b['x']+b['w']+pad and a['x']+a['w']>b['x']-pad and a['y']<b['y']+b['h']+pad and a['y']+a['h']>b['y']-pad
def run(day,recipe):
 s=baseline(day);old=copy.deepcopy(s);names,heights,material,width,gap=recipe;names=names.split('|');seed=int(day.replace('-',''))
 original_length=s['length'];boss='boss' in s
 if boss:
  # Keep the actual arena as the finale; the new approach begins in its old location.
  arena_platforms=copy.deepcopy(s['platforms']);s['platforms']=[];s['hazards']=[];s['signs']=[];s['decorations']=[];s['motes']=[];s['spawn']=[120,624]
  start=576
 else:start=original_length+384
 s['world_top']=-1536;s['abilities']=['charge_dash'];s['layout_revision']=int(s.get('layout_revision',1))+1
 # Keep the opening's established spring, lift and waterfall timing as a warmup.
 # The six longer challenge movements supply the sustained spike fields.
 points=[];rooms=[];x=start;last_y=624
 # A route has six independently named movements. Original routes remain its opening.
 # Explicit platform coordinates are baked; the game does not generate these at runtime.
 for room_index,elevations in enumerate(heights):
  room_start=x;room_points=[]
  for j,elevation in enumerate(elevations):
   y=624-elevation*48
   # Leave a full stable rest platform at each section boundary.
   w=(4 if j==0 or j==len(elevations)-1 else width)*48
   kind={'kind':'wood'} if material=='wood' else ({'kind':'ice'} if material=='ice' else {'kind':'block','material':material})
   if j in [0,len(elevations)-1]:kind={'kind':'block','material':'stone'}
   if day in ['09-14','10-12'] and room_index in [2,3] and j%3==1:kind={'kind':'crumble'}
   # Every other winter step exposes rock so the ice needs deliberate braking.
   if material=='ice' and j%3==0:kind={'kind':'block','material':'stone'}
   p={'x':x,'y':y,'w':w,'h':48,**kind};s['platforms'].append(p)
   target=[x+48,y]
   points.append({'at':target,'room':room_index,'kind':kind['kind']});room_points.append(target)
   if j==0:
    s['checkpoints'].append(target)
    s['signs'].append({'x':x+80,'y':y-142,'text':names[room_index]+'\n'+('Swim through the openings' if day=='11-19' else 'Aim up to charge-climb · land to recharge')})
   # Sharp far edges narrow the usable landing. There is always 96 px of safe deck.
   if j not in [0,len(elevations)-1] and w>=144:
    s['hazards'].append({'type':'bramble','x':x+w-48,'y':y-24,'w':48,'h':24,'direction':'up'})
   # Underside teeth and wall teeth make the vertical silhouettes unambiguous.
   if j%3==1:
    s['hazards'].append({'type':'bramble','x':x+48,'y':y+48,'w':48,'h':24,'direction':'down'})
   if j%4==2 and abs(y-last_y)<=96:
    s['hazards'].append({'type':'bramble','x':x+w,'y':y+4,'w':24,'h':40,'direction':'right'})
   for dx in [36,72]:s['motes'].append([x+dx,y-72])
   # Day-specific scenery anchors follow this elevated route rather than staying at ground.
   props=[d for d in old['decorations'] if d.get('layer','back')=='back' and 'x' in d and d['type'] not in ['riverbank','river_rapids','brook_cascade','railway','meadow_train']]
   if props and j in [0,3]:
    d=copy.deepcopy(props[(room_index*3+j+seed)%len(props)]);d['x']=x+30;d['y']=y+4;d['width']=min(d.get('width',100),240);d['height']=min(d.get('height',100),230);d['scale']=min(d.get('scale',.6),.6);s['decorations'].append(d)
   # Per-day gap rhythm. Longer intervals force dash commitment and shorter holds brake early.
   gap_blocks=gap+((j+room_index+seed)%3==0)
   x+=w+gap_blocks*48;last_y=y
  rooms.append({'name':names[room_index],'from_x':room_start,'to_x':x,'start':room_points[0],'end':room_points[-1]})
  x+=192
 # The run from the existing exit joins an ascending first room; flat escape is spiked.
 # Individually placed beds read as sustained fields, with stable rest islands below room starts.
 floor_safe=[q['at'] for q in points if q['at'][1]>=528]+[[start-144,624],[x+96,624]]
 for hx in range(start+144,x-48,96):
  h={'type':'bramble','x':hx,'y':600,'w':96,'h':24,'direction':'up'}
  if any(abs(c[0]-(hx+48))<144 for c in floor_safe):continue
  if any(rect_hits(h,p,0) for p in s['platforms'] if p['y']<624 and p['y']+p['h']>=600):continue
  s['hazards'].append(h)
 # Landing and visible gate after a safe descent. No blind fatal drop at the exit.
 points.append({'at':[x+96,624],'room':6,'kind':'ground'})
 if boss:
  arena_x=math.ceil((x+384)/48)*48;s['boss']['arena_x']=arena_x
  for p in arena_platforms:p['x']+=arena_x;s['platforms'].append(p)
  s['checkpoints'].append([arena_x+96,624]);s['goal']=[arena_x+1200,624];s['length']=arena_x+1296
  s['signs'].append({'x':arena_x+50,'y':432,'text':'THE SQUALLKEEPER\nThree phases · each phase saves your progress'})
  # Readable islands in the arena, in addition to the dense approach.
  for hx in [336,672,1008]:s['hazards'].append({'type':'bramble','x':arena_x+hx,'y':600,'w':48,'h':24,'direction':'up'})
 else:
  s['goal']=[x+288,624];s['length']=math.ceil((x+480)/48)*48
 if day=='11-19':
  s['zones'].append({'type':'water','x':original_length-192,'y':-1536,'w':s['length']-original_length+384,'h':2304,'swimmable':True})
  # Alternating chamber openings require changes in depth; swimming above every
  # challenge is not a route through the submerged tower.
  for r in rooms:
   gx=r['from_x']-96;gy=r['start'][1]
   s['platforms'].append({'x':gx,'y':-1536,'w':48,'h':gy-288+1536,'kind':'block','material':'stone'})
   s['hazards'].append({'type':'bramble','x':gx,'y':gy-288,'w':48,'h':24,'direction':'down'})
   if gy+96<624:
    s['platforms'].append({'x':gx,'y':gy+96,'w':48,'h':624-gy-96,'kind':'block','material':'stone'})
    s['hazards'].append({'type':'bramble','x':gx,'y':gy+72,'w':48,'h':24,'direction':'up'})
  for r in rooms[1:5:2]:s['zones'].append({'type':'current','x':r['from_x'],'y':-1152,'w':r['to_x']-r['from_x'],'h':1776,'force':[-150,-40],'submerged':True})
 # Subtle force signatures remain local and leave the landing route predictable.
 if day in ['03-09','04-11','06-06','06-17']:
  for r in [rooms[1],rooms[3]]:
   s['zones'].append({'type':'updraft','x':r['from_x']+192,'y':r['end'][1]-144,'w':144,'h':max(192,r['start'][1]-r['end'][1]+288),'force':[0,-1500]})
 elif day in ['06-03','06-15','07-16','08-23','10-12']:
  r=rooms[2];s['zones'].append({'type':'wind','x':r['from_x'],'y':min(p['at'][1] for p in points if p['room']==2)-192,'w':r['to_x']-r['from_x'],'h':576,'force':[100 if seed%2 else -100,0],'pulse':True})
 spikes=[h for h in s['hazards'] if h['type']=='bramble']
 s['challenge']={'revision':1,'original_length':original_length,'extension_start':start,'rooms':rooms,'route':points,'spike_placements':len(spikes),'visible_spikes':sum(int((h['h'] if h.get('direction') in ['left','right'] else h['w'])/12) for h in spikes),'vertical_travel':max(p['at'][1] for p in points)-min(p['at'][1] for p in points),'intent':'Longer precision route: alternating climbs, descents and narrow landing edges. Existing day identity and opening geometry retained.'}
 s['description']=old['description'].split('. ')[0].rstrip('.')+'. Climb '+names[3].lower()+' and descend through '+names[4].lower()+', with dense spikes and close landings.'
 assert len(spikes)>=50,(day,len(spikes));assert s['length']>=original_length*2,(day,s['length'],original_length)
 (P/'content/stages'/f'{day}.json').write_text(json.dumps(s,indent=2,ensure_ascii=False)+'\n')
 return {'id':day,'old_length':original_length,'length':s['length'],'spike_placements':len(spikes),'visible_spikes':s['challenge']['visible_spikes'],'vertical_travel':s['challenge']['vertical_travel'],'rooms':names}
report=[run(day,recipe) for day,recipe in ROUTES.items()]
(P/'content/challenge_report.json').write_text(json.dumps(report,indent=2)+'\n')
(P/'content/challenge_recipes.json').write_text(json.dumps({day:{'rooms':r[0].split('|'),'elevations':r[1],'material':r[2],'landing_blocks':r[3],'gap_blocks':r[4]} for day,r in ROUTES.items()},indent=2)+'\n')
print(json.dumps(report,indent=2))
