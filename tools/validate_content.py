#!/usr/bin/env python3
"""Validate the catalog before opening Godot. No external dependencies."""
import json, pathlib, re
root=pathlib.Path(__file__).resolve().parents[1]
load=lambda p:json.loads((root/p).read_text())
catalog=load('content/catalog.json'); calendar=load('content/calendar.json')
styles=load('content/terrain_styles.json')
roles={'outline','soil','soil_light','soil_dark','seam','grass','grass_shadow','top','wood','wood_light','wood_top'}
for name,style in styles.items():
 assert roles <= style.keys(), (name,'missing terrain palette role')
 assert all(re.fullmatch(r'[0-9a-fA-F]{6}',style[key]) for key in roles), (name,'invalid hex color')
decoration_types={'fence','hedge','flowers','flowerbed','tree','ivy','birdhouse','signpost','stone_wall','reeds','boulder','beehive',"willow","riverbank","dragonflies","kite","clover","orchard_tree","orchard_wall","trellis","railway","station","meadow_train","waterwheel","sluice","water_spray","sunflowers","hazel_arch","lantern_string","lantern_post","pavilion"}
decoration_types.add('orchard_crown')
decoration_types.update({'wheat','harvest_cart','storm_beacon','boathouse','copper_tree','flood_marker','snow_pine','winter_cabin','thaw_pool','snowdrop','blossom_tree','garden_arch','flower_meadow'})
decoration_types.update({'palm_planter', 'mill_tower', 'crossing_bridge', 'fruit_basket', 'wildflower_drift', 'river_rapids', 'hay_barn', 'trail_fingerpost', 'pollinators', 'woodland_trunk', 'glasshouse_bay', 'orchard_ladder', 'woodland_stump', 'fern_bed', 'hay_roll', 'river_boat', 'wind_ribbon', 'pool_lilies', 'brook_cascade', 'brook_arch'})
june_scenes=load('content/june_scenes.json')
for scene in june_scenes.values(): assert (root/scene['plate'].removeprefix('res://')).is_file()
assert len(calendar['days'])==365
assert len({d['id'] for d in calendar['days']})==365
assert sum(d['boss'] for d in calendar['days'])==12
assert set(catalog['featured']) <= set(catalog['stages'])
assert len(catalog['stages'])==len(set(catalog['stages']))
for id in catalog['stages']:
 s=load(f'content/stages/{id}.json'); assert s['id']==id and s['schema_version']==1
 assert id in {d['id'] for d in calendar['days']}
 assert (root/s['music'].removeprefix('res://')).is_file()
 if s.get('background'): assert (root/s['background'].removeprefix('res://')).is_file()
 assert s['season'] in load('content/themes.json')
 assert s.get('terrain_style',s['season']) in styles, (id,'unknown terrain style')
 assert s.get('decoration_profile','') in ['', 'early_summer'], (id,'unknown decoration profile')
 assert s.get('grid_size')==48, (id,'expected square block grid')
 if 'ground' in s: assert 580<=s['ground']['y']<=660, (id,'ground outside the visible play area')
 for d in s.get('decorations',[]):
  assert d['type'] in decoration_types, (id,'unknown decoration',d)
  assert d.get('layer','back') in ['back','front'], (id,'invalid decoration layer',d)
  if 'platform' in d:
   assert type(d['platform']) is int and 0<=d['platform']<len(s['platforms']), (id,'invalid decoration anchor',d)
  else:
   assert isinstance(d.get('x'),(int,float)) and isinstance(d.get('y'),(int,float)), (id,'decoration needs position or platform anchor',d)
  assert all(d.get(key,1)>0 for key in ['width','height','scale']), (id,'invalid decoration dimensions',d)
 for p in s['platforms']:
  assert p['kind'] in ['ground','wood','ice','moving','spring','crumble','block']
  if p['kind']=='block': assert p.get('material') in ['stone','hay','log']
  assert p['w']>0 and p['h']>0 and p['x']>=0
  assert all(p[key]%48==0 for key in ['x','y','w','h']), (id,'terrain is not on the block grid',p)
  if p['kind']=='moving': assert p['axis'] in ['x','y'] and p['distance']>0
 for z in s['zones']:
  assert z['type'] in ['water','wind','updraft','current']
  if 'swimmable' in z: assert z['type']=='water' and type(z['swimmable']) is bool and z['w']>0 and z['h']>0
 for h in s['hazards']:
  assert h['type'] in ['blade','thorn','icicle','bramble']
  if h['type']=='bramble': assert h['w']>0 and h['h']>0
  else: assert h['r']>0
 for pos in [s['spawn'],s['goal']]+s['checkpoints']:
  assert ('ground' in s and abs(pos[1]-s['ground']['y'])<=40) or any(p['x']-12<=pos[0]<=p['x']+p['w']+12 and abs(pos[1]-p['y'])<=50 for p in s['platforms']), (id,'unsafe spawn/goal/checkpoint',pos)
  assert not any(p['x']-12<pos[0]<p['x']+p['w']+12 and p['y']<pos[1] and p['y']+p['h']>pos[1]-42 for p in s['platforms']), (id,'checkpoint intersects an obstacle',pos)
 print(f"OK {id}: {len(s['platforms'])} platforms, {len(s['motes'])} sunmotes, {len(s['checkpoints'])} checkpoints")
print(f"Validated {len(catalog['stages'])} stages and 365 dates.")
