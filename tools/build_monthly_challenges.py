#!/usr/bin/env python3
"""Offline authoring source for 132 readable platforming challenges. Never runs in the game.

Eleven architectural forms combine in distinct four-place itineraries. Month
physics, dimensions, surfaces, machine choreography and scenery are explicit
in the emitted blueprints, which can be independently edited thereafter.
Re-run only when deliberately replacing the challenge blueprints, then compile.
"""
from pathlib import Path
import argparse, json, math, colorsys

ROOT = Path(__file__).resolve().parents[1]
MONTHS = [6,7,8,9,10,11,12,1,2,3,4,5]
TITLES = {
6: ['The Razorwind Pasture','Foxglove Freefall','The Broken Stile','Sunwheel Spires','Bramble Bellows','The Beekeeper’s Needle','The Gallows Orchard','Cloverlock Canal','Thirteen Haylofts','The Skylark Crucible','Noon Above the Thorns'],
7: ['The Saffron Furnace','Barleyknife Ravine','The Copper Silo','White Heat Viaduct','Cicada Overdrive','The Scorched Granary','Heliostat Heights','The Dry Well Engine','Sunstroke Switchback','The Thresher’s Crown','High Summer Hellgate'],
8: ['The Amber Breakwater','Thunder on the Moorings','The Golden Bell Tower','Stormglass Quarry','The Last Light Rig','Copper Rain Causeway','The Creaking Drydock','The Lightning Orchard','Floodgate at Dusk','The Horizon Engine','Sunset’s Falling Teeth'],
9: ['The Redleaf Guillotine','Acorn Ironworks','The Auburn Belfry','The Mushroom Needle','The Copper Canopy','Leafstorm Sawmill','The Hollow Chestnut','The Harvest Pendulum','The Russet Labyrinth','Briarwood Observatory','The Last Falling Leaf'],
10: ['The Blackcloud Dynamo','Thundercoil Cathedral','The Weather Vane Trap','The Flashflood Organ','Lightning in the Rafters','The Stormwatch Spindle','The Cinderbell Crossing','Rainwire Crucible','The Broken Conductor','The Gale’s Drawbridge','The Eye of the Machine'],
11: ['The Submerged Belfry','Pressure at Blackwater','The Kelpbound Turbine','The Sunken Signal Box','The Drowned Clockface','The Silt Cathedral','The Undertow Cage','The Flooded Foundry','The Rustwater Needle','The Abyssal Lock','The Last Airless Garden'],
12: ['The Frostline Furnace','The Snowblind Sluice','The Icicle Bell Tower','The Frozen Boiler','Steam in the Fir Trees','The Avalanche Gantry','The Winterglass Gallery','The Whiteout Mill','The Coalstar Chimney','The Silent Snowpress','Embers Under Ice'],
1: ['The Blueice Guillotine','The Glacier Clock','The Hoarfrost Cathedral','The Black Ice Circuit','The Frozen Pendulum','The Polar Gearhouse','The Splintering Rink','The Aurora Spindle','The Ice Organ','The Midnight Crevasse','The Deep Winter Crown'],
2: ['The Meltwater Trap','Snowdrop Sawmill','The Thawing Belfry','The Cracked Reservoir','The Dripping Crown','The Last Frost Engine','The Crocus Guillotine','The Slushwater Circuit','The Hollow Icehouse','The Returning Briar','The Breakup Cascade'],
3: ['The Cascade Helix','The Waterfall Needle','The Crosswind Organ','The Rapids Dynamo','The Mistbound Viaduct','The Whitewater Spindle','The Roaring Aqueduct','The Updraft Cathedral','The Torrent’s Teeth','The Stormwater Crown','The Falls Without End'],
4: ['The Blossom Guillotine','The Rainbow Dynamo','The Rainwater Belfry','The Petalwind Spire','The Greenhouse Needle','The Showerbound Switchyard','The Orchard Siphon','The Roseglass Organ','The Wisteria Circuit','The Pollenstorm Mill','The Last Rain Gate'],
5: ['The Verdant Crucible','The Rosewheel Cathedral','The Foxglove Crown','The Garden of Blades','The Honeysuckle Helix','The Sunlit Siphon','The Laurel Guillotine','The Mayfly Ironworks','The Briar’s Final Waltz','The Emerald Observatory','The Year’s Last Thorn']}
PALETTES = {
6:['74bfd9','dbeccd','9fc5b4','6d9d78','487355','efd793'],7:['68b6d0','f0e4b2','acb77b','968d4f','666c3f','f3c363'],
8:['617eab','edb59c','b69591','8b7771','555366','eab468'],9:['8b9caa','e4cbb6','b6a185','987346','625347','e4a56a'],
10:['344966','909eae','61768a','42566e','273e53','cbba85'],11:['193c50','56868b','3e7579','2b575e','193f4a','86c5bc'],
12:['8baac6','e0e8ec','bdcbd2','829ea8','506c7a','e5dcb0'],1:['415d87','b7d5e2','85aec6','5e88a6','365a77','c6eff1'],
2:['8fa6b4','e6e2d7','bdc6bb','8daba3','587c79','dfceae'],3:['5a9bb5','d2e8dd','84b6b4','598c8c','346674','add9c9'],
4:['92bed2','f2dbd7','b7c5b0','839e8a','527f72','edbdc8'],5:['79b6b8','e9e9bf','acc891','789d68','477859','f3cf9c']}
PROFILE = {
6:('june','june','field',['windmill','bloom','shutter'],'wildflower_drift'),7:('mill','july','barley',['press','windmill','sawrail'],'wheat'),
8:('boss','august','lake',['pendulum','arc','shutter'],'storm_beacon'),9:('autumn','september','orchard',['bloom','sawrail','pendulum'],'copper_tree'),
10:('boss','boss','ridge',['arc','windmill','press'],'storm_beacon'),11:('boss','november','underwater',['shutter','sawrail','geyser'],'reeds'),
12:('winter','december','snow',['geyser','press','pendulum'],'snow_pine'),1:('winter','winter','ice',['sawrail','pendulum','press'],'snow_pine'),
2:('winter','february','thaw',['bloom','geyser','sawrail'],'snowdrop'),3:('spring','spring','waterfall',['windmill','geyser','arc'],'river_rapids'),
4:('spring','april','garden',['shutter','arc','bloom'],'blossom_tree'),5:('spring','may','flowers',['bloom','windmill','pendulum'],'flower_meadow')}
FORMS = ['Sail helix','Needle descent','Press vault','Counterweight well','Fracture staircase','Moving freight','Crosswind chimney','Canopy zipper','Bell circuit','Floodgate organ','Crown transfer']
LANDMARKS = ['mill','aqueduct','factory','belfry','ruins','railway','waterfall','glasshouse','clock','sluice','observatory']

def write(path, value): path.write_text(json.dumps(value,indent=2,ensure_ascii=False)+'\n')
def block(x,y,w=96,kind='wood',h=48,**kw):
    p=dict(x=int(x),y=int(y),w=int(w),h=int(h),kind=kind,**kw)
    if kind=='block':p.setdefault('material','stone')
    return p
def spike(x,y,w=48,h=24,direction='up'):return dict(type='bramble',x=x,y=y,w=w,h=h,direction=direction)
def machine(kind,x,y,identity,i,mi=0):
    h=dict(type='mechanism',mechanism=kind,id=f'{identity}-m{i}',x=x,y=y,
           period=4.6+(i%3)*.3,phase=round((i*.47+mi*.11)%3,3),safe_seconds=1.4,
           warning_seconds=.75,extension_seconds=.18,color=PALETTES[MONTHS[mi]][-1])
    if kind=='windmill':h.update(y=y-136,radius=120,blades=3,rotation_direction=1 if i%2 else -1,thickness=7,period=7.6)
    elif kind=='pendulum':h.update(y=y-180,radius=158,head_radius=21,swing=.82,period=5.6)
    elif kind in ['press','shutter','geyser']:h.update(x=x-24,y=y-144,w=48,h=144)
    elif kind=='bloom':h.update(y=y-24,head_radius=32)
    elif kind=='sawrail':h.update(y=y-24,head_radius=22,travel=42)
    elif kind=='arc':h.update(y=y-144,dx=0,dy=144,thickness=6)
    return h

def scene(mi,k,ri,form):
    # Editable composition, not a recoloured copy of a bitmap. Each skyline has
    # its own silhouettes, landmark scale/placement, waterline and atmosphere.
    seed=mi*53+k*17+ri*29
    palette=[]
    for hx in PALETTES[MONTHS[mi]]:
        rgb=[int(hx[i:i+2],16)/255 for i in (0,2,4)];hh,ss,vv=colorsys.rgb_to_hsv(*rgb)
        rr=colorsys.hsv_to_rgb((hh+(k-5)*.004+ri*.003)%1,ss,max(.1,min(1,vv+(ri-1.5)*.012)))
        palette.append(''.join(f'{round(c*255):02x}' for c in rr))
    ridges=[]
    for depth in range(3):
        ridges.append([[x,round(300+depth*82+math.sin((x+seed*9)/(150+depth*39))*52+math.cos((x-seed*5)/91)*23)] for x in range(-120,1441,60)])
    structures=[]
    for j in range(3+(k+ri)%3):
        structures.append(dict(kind=LANDMARKS[(form+j*(1+mi%2))%11],x=80+j*320+(seed+j*67)%135,y=500+(j%2)*42,w=100+(seed+j*53)%140,h=130+(seed*3+j*29)%210))
    return dict(palette=palette,ridges=ridges,structures=structures,sun=[150+(seed*37)%1000,75+(seed*7)%130,36+(k*7+ri*11)%50],
                waterline=485+(seed%4)*32,weather='bubbles' if MONTHS[mi]==11 else ('snow' if MONTHS[mi] in [12,1] else ('rain' if MONTHS[mi] in [8,10,3,4] else 'pollen')),
                seed=seed,foliage=MONTHS[mi] not in [11,12,1],moon=MONTHS[mi] in [10,1],style=LANDMARKS[form])

# Deliberate route silhouettes: clear decks alternate with committed transfers.
# Two machines per place, never on the arrival or departure edge of a deck.
PATTERNS={
0:[(288,528,576),(1200,384,576),(2112,192,576),(3024,384,576)],
1:[(288,528,576),(1104,288,576),(1968,48,576),(2880,336,624)],
2:[(288,528,528),(1056,432,624),(2016,432,624),(2976,528,576)],
3:[(288,528,576),(1152,336,576),(2016,432,576),(2928,192,624)],
4:[(288,528,576),(1152,432,240),(1680,336,576),(2544,432,240),(3072,528,576)],
7:[(288,528,576),(1152,384,576),(2016,384,576),(2880,528,624)],
8:[(288,528,576),(1152,336,576),(2016,144,576),(2928,336,576)],
9:[(288,528,624),(1200,288,576),(2112,384,576),(3024,192,624)],
10:[(288,528,576),(1200,288,576),(2112,48,576),(3024,288,624)]}

def route_node(x,y,action='walk',**kw):return dict(at=[x,y],action=action,**kw)

def add_crossing(s,p,kind,identity,index,mi):
    center=p['x']+p['w']/2;at=p['y']
    h=machine(kind,center,at,identity,index,mi);s['hazards'].append(h)
    s['route'] += [route_node(center-156,at),route_node(center+156,at,'mechanism',obstacle_id=h['id']),route_node(p['x']+p['w']-60,at)]

def section(mi,k,ri,ox):
    month=MONTHS[mi];form=(k*3+mi*2+ri*(1+mi%3))%11
    width=4320+48*(k%3)+96*(mi%2);dx=48*(mi%3);dy=-48*(k%2)
    water=month==11;identity=f'{month:02d}-X{k+1:02d}-r{ri}'
    primary=PROFILE[month][3][(form+k)%3];secondary=PROFILE[month][3][(form+k+1)%3]
    s=dict(name=FORMS[form],origin=[ox,0],width=width,lesson='Observe the machine, cross its opening, then prepare the next transfer.',
           platforms=[],hazards=[],zones=[],motes=[],checkpoints=[] if ri==0 else [[96,528 if water else 624]],
           decorations=[],signs=[dict(x=120,y=440,text=FORMS[form]+'\nRead the rhythm. Catch the clear deck.')],route=[route_node(120 if ri==0 else 96,528 if water else 624,'start')],
           visual=dict(place=PROFILE[month][2],light=['morning','shade','interior','sunset'][ri],art_cell=ri,composition=scene(mi,k,ri,form)))
    if water:
        s['zones']=[dict(type='water',x=0,y=-960,w=width,h=1680,swimmable=True)]
        s['platforms'].append(block(0,-960,width,'block'))
        levels=[336,48,-240,0,288]
        for j in range(5):
            x=624+j*672+dx;y=levels[(j+form)%5]-48*(k%2)
            top=y-144;bottom=y+96
            s['platforms'] += [block(x,-912,96,'block',top+912),block(x,bottom,96,'block',624-bottom)]
            s['route'].append(route_node(x-168,y,'swim'))
            if j in [1,3]:
                h=machine('shutter' if j==1 else 'sawrail',x+48,y,identity,j,mi)
                h.update(safe_seconds=2.2,warning_seconds=.85,period=5.7)
                if h['mechanism']=='shutter':h.update(x=x+24,y=top,w=48,h=240)
                s['hazards'].append(h)
                s['route'].append(route_node(x+264,y,'mechanism',obstacle_id=h['id']))
            else:s['route'].append(route_node(x+264,y,'swim'))
            s['motes'] += [[x-100,y-35],[x+48,y-40],[x+200,y-35]]
            for yy in range(-864,top-48,48):s['hazards'].append(spike(x-24,yy,24,48,'left'))
        s['route'].append(route_node(width-96,528,'swim'))
    elif form==5:
        # Slow freight pauses at both docks. The next hazard is after disembarking.
        track=identity+'-freight'
        s['platforms']=[block(192+dx,528,240,'block',96),block(432+dx,528,192,'moving',axis='x',distance=48,speed=1,
            motion_path=[[0,0],[0,0],[528,0],[864,-192],[864,-192],[0,-192]],motion_seconds=10.8,motion_phase=0,track_id=track),
            block(1488+dx,336,384),block(1968+dx,240,576),block(2928+dx,432,624)]
        s['route'] += [route_node(288+dx,528,'jump'),route_node(528+dx,528,'board',track_id=track),route_node(1536+dx,336,'ride',track_id=track),route_node(1800+dx,336)]
        for index,p in enumerate(s['platforms'][3:]):
            s['route'].append(route_node(p['x']+72,p['y'],'dash'));add_crossing(s,p,primary if index==0 else secondary,identity,index,mi)
    elif form==6:
        s['platforms']=[block(288+dx,528,480),block(1104+dx,288,528),block(1968+dx,48,576),block(2832+dx,288,576)]
        s['zones']=[dict(type='updraft',x=816+dx,y=96,w=192,h=528,force=[0,-3650]),dict(type='updraft',x=1680+dx,y=-144,w=192,h=528,force=[0,-3650])]
        s['route'] += [route_node(360+dx,528,'jump'),route_node(708+dx,528),route_node(912+dx,480,'flow_enter'),route_node(1176+dx,288,'flow_exit',shaft_x=912+dx)]
        add_crossing(s,s['platforms'][1],primary,identity,0,mi)
        s['route'] += [route_node(1776+dx,240,'flow_enter'),route_node(2040+dx,48,'flow_exit',shaft_x=1776+dx),route_node(2484+dx,48),route_node(2904+dx,288,'dash')]
        add_crossing(s,s['platforms'][3],secondary,identity,1,mi)
    else:
        entries=PATTERNS[form]
        for j,(x,y,w) in enumerate(entries):
            kind='crumble' if form==4 and j in [1,3] else ('ice' if month==1 or month in [12,2] and j%3==0 else 'wood')
            p=block(x+dx,y+dy,w,kind);s['platforms'].append(p)
            s['route'].append(route_node(p['x']+72,p['y'],'jump' if j==0 else 'dash'))
            gate=j in ([0,2] if form==4 else [1,3])
            if gate:add_crossing(s,p,primary if j<2 else secondary,identity,j,mi)
            else:s['route'].append(route_node(p['x']+p['w']-60,p['y']))
            if form in [2,7] and gate:
                # Canopy constrains the crossing, not the landing or jump approach.
                s['platforms'].append(block(p['x']+144,p['y']-192,p['w']-288,'wood'))
        if month in [7,8,10,3,4] and form in [0,8,10]:
            # Brief wind patch over one transfer; takeoff and landing stay neutral.
            first=s['platforms'][0];second=s['platforms'][1]
            s['zones'].append(dict(type='wind',x=first['x']+first['w']+24,y=-576,w=max(48,second['x']-first['x']-first['w']-48),h=1152,force=[120 if ri%2==0 else -120,0]))
    if not water:s['route'].append(route_node(width-120,624,'drop'))
    # Failure beds sit well below the required catches, never on every surface.
    # Small gaps between beds and checkpoint islands keep the scene legible.
    for x in range(336+dx,width-576,48):
        if x%(864)<672:s['hazards'].append(spike(x,600))
    if not water:
        for p in s['platforms']:
            if p['kind'] in ['moving','block'] or p['y']< -200:continue
            s['motes'] += [[p['x']+90,p['y']-66],[p['x']+p['w']-84,p['y']-70]]
            s['decorations'].append(dict(type=PROFILE[month][4],x=p['x']+30,y=p['y'],width=72,height=64,scale=.45,layer='back'))
    if not water:
        final_deck=max((p for p in s['platforms'] if p['w']>=480),key=lambda p:p['x'])
        final_deck['w']+=48*(mi//3)
    return s

def build():
    manifest=[]
    for mi,month in enumerate(MONTHS):
        season,terrain,place,mechanisms,deco=PROFILE[month]
        for k,title in enumerate(TITLES[month]):
            id=f'{month:02d}-X{k+1:02d}';sections=[];ox=0
            for ri in range(4):
                s=section(mi,k,ri,ox);sections.append(s);ox+=s['width']
            for ri,s in enumerate(sections):s['name']=title.split('The ')[-1]+' / '+s['name'];s['signs'][0]['text']=s['name']+'\nRead the rhythm. Catch the clear deck.'
            intent=f'{title}. '+', '.join(s['name'].split(' / ')[-1].lower() for s in sections)+'. '+('Fully submerged passages with timed sluice gates.' if month==11 else ('Ice momentum throughout.' if month==1 else 'Four linked platforming trials with clear recovery decks.'))
            spawn=[120,528 if month==11 else 624];goal=[ox-96,spawn[1]]
            layout=dict(schema_version=1,revision=19,day=id,identity=title,intent=intent,world_top=-960,spawn=spawn,length=ox,goal=goal,sections=sections,journey=True,secret_areas=[],
                        scenery=dict(renderer='composition',revision=1),difficulty=dict(edition='challenge',signature=mechanisms[k%3],secondary=mechanisms[(k+1)%3],reachability_tested=False))
            stage=dict(schema_version=1,id=id,title=title,season=season,terrain_style=terrain,description=intent,music=f'res://audio/challenges/{id}.wav',grid_size=48,length=ox,ground=dict(y=624),challenge=dict(original_length=1536),
                       monthly_challenge=dict(month=month,number=k+1),ambience=dict(haze=PALETTES[month][2],separation=.58))
            write(ROOT/'content/layouts'/f'{id}.json',layout);write(ROOT/'content/stages'/f'{id}.json',stage)
            manifest.append(dict(id=id,month=month,number=k+1,title=title,places=[s['name'] for s in sections],signature=layout['difficulty']['signature'],length=ox))
    write(ROOT/'content/monthly_challenges.json',manifest)
    catalog=json.loads((ROOT/'content/catalog.json').read_text());catalog['challenges']=[s['id'] for s in manifest];write(ROOT/'content/catalog.json',catalog)
    print('Authored 132 readable challenge routes / 528 places. Run route verification before delivery.')

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--write',action='store_true');args=p.parse_args()
    if not args.write:p.error('Use --write to deliberately replace monthly challenge blueprints.')
    build()
