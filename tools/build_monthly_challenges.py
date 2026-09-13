#!/usr/bin/env python3
"""Offline authoring source for 132 extreme challenges. Never runs in the game.

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
           period=round(.95+(i%7)*.11,3),phase=round((i*.317+mi*.13)%1.4,3),safe_seconds=.12,
           warning_seconds=.16,extension_seconds=.06,color=PALETTES[MONTHS[mi]][-1])
    if kind=='windmill':h.update(y=y-128,radius=144+(i%3)*24,blades=4,rotation_direction=1 if i%2 else -1,thickness=10,period=1.8+(i%4)*.17)
    elif kind=='pendulum':h.update(y=y-216,radius=204,head_radius=32,swing=1.15,period=1.6+(i%5)*.13)
    elif kind in ['press','shutter','geyser']:h.update(x=x-24,y=y-192,w=48+(i%2)*48,h=192)
    elif kind=='bloom':h.update(y=y-38,head_radius=52)
    elif kind=='sawrail':h.update(y=y-32,head_radius=30,travel=108+(i%3)*12)
    elif kind=='arc':h.update(y=y-192,dx=96 if i%2 else 0,dy=192,thickness=9)
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

def section(mi,k,ri,ox):
    month=MONTHS[mi];form=(k*3+mi*2+ri*(1+mi%3))%11
    width=(64+2*((k+mi+ri)%5))*48
    water=month==11
    s=dict(name=FORMS[form],origin=[ox,0],width=width,lesson=FORMS[form]+' · extreme timing and narrow catches.',
           platforms=[],hazards=[],zones=[],motes=[],checkpoints=[] if ri==0 else [[96,528 if water else 624]],
           decorations=[],signs=[dict(x=144,y=440,text=FORMS[form]+'\nExtreme route')],route=[dict(at=[120 if ri==0 else 96,528 if water else 624],action='start')],
           visual=dict(place=PROFILE[month][2],light=['morning','shade','interior','sunset'][ri],art_cell=ri,composition=scene(mi,k,ri,form)))
    n=8+(k+ri)%4;step=((width-624)//(n*48))*48
    placements=[]
    for j in range(n):
        x=336+j*step
        if form==0:y=480-(j%5)*192
        elif form==1:y=-576+(j%7)*144
        elif form==2:y=432 if j%2==0 else 192
        elif form==3:y=432-((j*3)%7)*144
        elif form==4:y=432-j*96
        elif form==5:y=480-(j%4)*240
        elif form==6:y=384-((j+ri)%6)*192
        elif form==7:y=480 if j%2 else -96-(k%3)*96
        elif form==8:y=288-round(math.sin(j*math.pi/3)*5)*96
        elif form==9:y=384-((j*2+ri)%6)*192
        else:y=480-((j*3+k)%8)*144
        y-=48*((mi+k+ri)%3)
        w=48*(1+(j+k+mi)%3)
        kind='ice' if month==1 or (month in [12,2] and j%3==0) else ('crumble' if form in [1,4] or (month==2 and j%2) else 'wood')
        p=block(x,y,w,kind)
        if form==5 or (month==4 and j%3==1):p.update(kind='moving',axis='y' if j%2 else 'x',distance=96+(j%3)*48,speed=3.4+(k%4)*.55,phase=j*.73)
        if form==8 and j%3==0:p.update(kind='spring',power=1000+(k%4)*90)
        s['platforms'].append(p);placements.append((x,y,w))
        s['motes'].append([x+w/2,y-72]);s['route'].append(dict(at=[x+w/2,y],action='unverified'))
        s['hazards'] += [spike(x,y+48,w,24,'down')]
        if w>=96:s['hazards'].append(spike(x if j%2 else x+w-48,y-24))
        if form in [2,7,9]:
            s['platforms'].append(block(x,y-192,w+48,'block'))
            s['hazards'].append(spike(x,y-144,w+48,24,'down'))
        if form in [3,6,9] and j%2==0:
            s['platforms'].append(block(x+144,y+96,48,'block',min(624-y-96,432)))
            for yy in range(y+96,min(624,y+528),48):s['hazards'].append(spike(x+120,yy,24,48,'left'))
        if j%2==0:s['decorations'].append(dict(type=PROFILE[month][4],x=x+12,y=y,width=72,height=96,scale=.5,layer='back'))
    signature=PROFILE[month][3]
    for j,(x,y,w) in enumerate(placements):
        for q in range(4):
            kind=signature[(j+q+form)%3]
            h=machine(kind,x+w/2+(q-1)*72,y-((q%2)*144),f'{month:02d}-X{k+1:02d}-r{ri}',j*4+q,mi)
            s['hazards'].append(h)
    # The ground is continuous but packed with banks of spikes. Each chamber
    # leaves only a small arrival/exit island; this is not a path feasibility rule.
    for x in range(240,width-240,48):s['hazards'].append(spike(x,600))
    if form in [0,6,10] or month==3:
        for j in range(3):s['zones'].append(dict(type='updraft',x=480+j*864,y=-1200,w=192,h=1824,force=[(-1 if j%2 else 1)*160,-1650-(k%3)*180]))
    if month in [7,8,10,3,4]:
        for j in range(3):s['zones'].append(dict(type='wind',x=672+j*816,y=-1248,w=480,h=1680,force=[(-1 if (j+k)%2 else 1)*(650+mi*25),0]))
    if water:
        s['zones'].append(dict(type='water',x=0,y=-1536,w=width,h=2256,swimmable=True))
        for j in range(4):s['zones'].append(dict(type='current',x=384+j*624,y=-1296,w=432,h=1728,force=[(-1 if j%2 else 1)*700,(-1 if (j+k)%2 else 1)*400]))
    s['route'].append(dict(at=[width-96,528 if water else 624],action='unverified'))
    return s

def build():
    manifest=[]
    for mi,month in enumerate(MONTHS):
        season,terrain,place,mechanisms,deco=PROFILE[month]
        for k,title in enumerate(TITLES[month]):
            id=f'{month:02d}-X{k+1:02d}';sections=[];ox=0
            for ri in range(4):
                s=section(mi,k,ri,ox);sections.append(s);ox+=s['width']
            for ri,s in enumerate(sections):s['name']=title.split('The ')[-1]+' / '+s['name'];s['signs'][0]['text']=s['name']+'\nExtreme route'
            intent=f'{title}. '+', '.join(s['name'].split(' / ')[-1].lower() for s in sections)+'. '+('Fully submerged, with alternating undertows.' if month==11 else ('Ice momentum throughout.' if month==1 else 'Four linked extreme trials.'))
            spawn=[120,528 if month==11 else 624];goal=[ox-96,spawn[1]]
            layout=dict(schema_version=1,revision=18,day=id,identity=title,intent=intent,world_top=-1536,spawn=spawn,length=ox,goal=goal,sections=sections,journey=True,secret_areas=[],
                        scenery=dict(renderer='composition',revision=1),difficulty=dict(edition='extreme',signature=mechanisms[k%3],secondary=mechanisms[(k+1)%3],reachability_tested=False))
            stage=dict(schema_version=1,id=id,title=title,season=season,terrain_style=terrain,description=intent,music=f'res://audio/challenges/{id}.wav',grid_size=48,length=ox,ground=dict(y=624),challenge=dict(original_length=1536),
                       monthly_challenge=dict(month=month,number=k+1),ambience=dict(haze=PALETTES[month][2],separation=.58))
            write(ROOT/'content/layouts'/f'{id}.json',layout);write(ROOT/'content/stages'/f'{id}.json',stage)
            manifest.append(dict(id=id,month=month,number=k+1,title=title,places=[s['name'] for s in sections],signature=layout['difficulty']['signature'],length=ox))
    write(ROOT/'content/monthly_challenges.json',manifest)
    catalog=json.loads((ROOT/'content/catalog.json').read_text());catalog['challenges']=[s['id'] for s in manifest];write(ROOT/'content/catalog.json',catalog)
    print('Authored 132 challenge blueprints / 528 places. No reachability tests performed.')

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--write',action='store_true');args=p.parse_args()
    if not args.write:p.error('Use --write to deliberately replace monthly challenge blueprints.')
    build()
