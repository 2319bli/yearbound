class_name YBLayoutDocument
extends RefCounted

const TILE=48
const ROWS=15
const MAX_COLUMNS=2048
const MIN_TOP=-3072
const SEASONS=["june","mill","boss","autumn","winter","spring"]
var stage: Dictionary={}
var cells: Dictionary={}
var history: Array[Dictionary]=[]
var future: Array[Dictionary]=[]
var pending: Dictionary={}
var revision=0

static func key(at: Vector2i) -> String: return "%d:%d" % [at.x,at.y]
static func coord(value: String) -> Vector2i:
	var parts=value.split(":");return Vector2i(int(parts[0]),int(parts[1]))
static func blank() -> Dictionary:
	var base=JSON.parse_string(FileAccess.get_file_as_string("res://content/stages/06-01.json"))
	var installed=JSON.parse_string(FileAccess.get_file_as_string("res://content/catalog.json")).stages
	for date in JSON.parse_string(FileAccess.get_file_as_string("res://content/calendar.json")).days:
		if date.id not in installed: base.id=date.id;break
	base.title="A day of your own";base.description="A layout made in the Yearbound workshop."
	base.length=4608;base.spawn=[120,624];base.goal=[4488,624]
	base.platforms=[];base.motes=[];base.checkpoints=[];base.hazards=[];base.zones=[];base.signs=[];base.decorations=[]
	base.erase("decoration_profile");base.erase("challenge");base["world_top"]=0;base["abilities"]=["charge_dash"];base["editor_version"]=2
	return base
func load_stage(value: Dictionary) -> void:
	stage=value.duplicate(true);cells.clear();history.clear();future.clear();pending.clear()
	stage["grid_size"]=TILE;stage["editor_version"]=2
	for p in stage.platforms:
		var data: Dictionary=p.duplicate(true)
		for field in ["x","y","w","h"]: data.erase(field)
		for y in range(int(p.y)/TILE,mini(ROWS,ceili((p.y+p.h)/TILE))):
			for x in range(int(p.x)/TILE,ceili((p.x+p.w)/TILE)):
				cells[key(Vector2i(x,y))]=data.duplicate(true)
	if stage.has("ground"):
		for x in ceili(float(stage.length)/TILE):
			for y in range(int(stage.ground.y)/TILE,ROWS):
				var k=key(Vector2i(x,y))
				if not cells.has(k): cells[k]={"kind":"ground"}
		stage.erase("ground")
	stage.platforms=[];revision+=1
func state() -> Dictionary: return {"stage":stage.duplicate(true),"cells":cells.duplicate(true)}
func begin_edit() -> void:
	if pending.is_empty(): pending=state()
func end_edit() -> bool:
	if pending.is_empty(): return false
	var changed=stage!=pending.stage or cells!=pending.cells
	if changed:
		history.append(pending);future.clear();revision+=1
		if history.size()>60: history.pop_front()
	pending={};return changed
func undo() -> bool:
	if history.is_empty(): return false
	future.append(state());restore(history.pop_back());return true
func redo() -> bool:
	if future.is_empty(): return false
	history.append(state());restore(future.pop_back());return true
func restore(value: Dictionary) -> void:
	stage=value.stage.duplicate(true);cells=value.cells.duplicate(true);pending={};revision+=1
func columns() -> int: return int(stage.length)/TILE
func first_row() -> int: return int(stage.get("world_top",0))/TILE
func row_count() -> int: return ROWS-first_row()
func inside(at: Vector2i) -> bool: return at.x>=0 and at.x<columns() and at.y>=first_row() and at.y<ROWS
func resize_height(rows: int) -> String:
	var top=(ROWS-clampi(rows,ROWS,ROWS-int(MIN_TOP)/TILE))*TILE
	for k in cells:
		if coord(k).y*TILE<top: return "Erase blocks above the new ceiling first."
	for pos in [stage.spawn,stage.goal]+stage.motes+stage.checkpoints:
		if pos[1]<top+48: return "Move markers below the new ceiling first."
	for field in ["hazards","zones","decorations","signs"]:
		for item in stage[field]:
			if item.y<top: return "Move objects below the new ceiling first."
	begin_edit();stage["world_top"]=top;end_edit();return ""
static func material(tool: String) -> Dictionary:
	if tool in ["stone","hay","log"]: return {"kind":"block","material":tool}
	if tool in ["lift_x","lift_y"]: return {"kind":"moving","axis":"x" if tool=="lift_x" else "y","distance":96,"speed":1.0}
	if tool=="spring": return {"kind":"spring","power":840}
	return {"kind":tool}
func paint(at: Vector2i, tool: String) -> void:
	if not inside(at): return
	var pos=Vector2(at)*TILE
	var center=pos+Vector2(24,24)
	if tool=="erase":
		cells.erase(key(at))
		for field in ["motes","checkpoints"]:
			for i in range(stage[field].size()-1,-1,-1):
				var item=stage[field][i];var point=Vector2(item[0],item[1]-(1 if field=="checkpoints" else 0))
				if Rect2(pos,Vector2(TILE,TILE)).has_point(point): stage[field].remove_at(i)
		for field in ["hazards","zones","decorations","signs"]:
			for i in range(stage[field].size()-1,-1,-1):
				var item=stage[field][i]
				var rect=Rect2(item.x,item.y,item.get("w",48),item.get("h",48))
				if field=="decorations": rect=Rect2(item.x-24,item.y-48,48,48)
				if rect.intersects(Rect2(pos,Vector2(48,48))): stage[field].remove_at(i)
	elif tool in ["ground","stone","wood","hay","log","ice","spring","crumble","lift_x","lift_y"]:
		cells[key(at)]=material(tool)
	elif tool in ["spawn","goal"]: stage[tool]=[center.x,pos.y+48]
	elif tool in ["mote","checkpoint"]:
		var field="motes" if tool=="mote" else "checkpoints"
		var point=[center.x,center.y] if tool=="mote" else [center.x,pos.y+48]
		if not contains(stage[field],point): stage[field].append(point)
	elif tool.begins_with("spikes"):
		var direction=tool.trim_prefix("spikes_") if "_" in tool else "up"
		var h={"type":"bramble","x":pos.x,"y":pos.y+24,"w":48,"h":24,"direction":direction}
		if direction=="down": h.y=pos.y
		elif direction in ["left","right"]:
			h.w=24;h.h=48;h.y=pos.y;h.x=pos.x+(24 if direction=="right" else 0)
		if not contains(stage.hazards,h): stage.hazards.append(h)
	elif tool in ["tree","flowers"]:
		var d={"type":tool,"x":center.x,"y":pos.y+48,"layer":"back","season":stage.season,"scale":0.7,"width":48}
		if not contains(stage.decorations,d): stage.decorations.append(d)
	elif tool in ["wind","updraft","current"]:
		var z={"type":tool,"x":pos.x,"y":pos.y,"w":48,"h":48,"force":[520,0]}
		if tool=="updraft": z.force=[0,-3650]
		if tool=="current": z.force=[760,-120]
		if not contains(stage.zones,z): stage.zones.append(z)
func paint_line(a: Vector2i, b: Vector2i, tool: String) -> void:
	var steps=maxi(absi(b.x-a.x),absi(b.y-a.y))
	for i in steps+1:
		paint(Vector2i(Vector2(a).lerp(Vector2(b),float(i)/maxi(1,steps)).round()),tool)
func paint_rectangle(a: Vector2i,b: Vector2i,tool: String) -> void:
	for y in range(maxi(first_row(),mini(a.y,b.y)),mini(ROWS-1,maxi(a.y,b.y))+1):
		for x in range(maxi(0,mini(a.x,b.x)),mini(columns()-1,maxi(a.x,b.x))+1): paint(Vector2i(x,y),tool)
func resize_columns(count: int) -> String:
	count=clampi(count,27,MAX_COLUMNS)
	var old=columns()
	if count==old: return ""
	if count<old:
		for k in cells:
			var c=coord(k)
			if c.x>=count and (c.y<13 or cells[k].kind!="ground"): return "Erase the blocks beyond the new end before shortening the day."
		for pos in [stage.spawn]+stage.motes+stage.checkpoints:
			if pos[0]>=count*48: return "Move markers and sunmotes inside the new end first."
		for field in ["hazards","zones","decorations","signs"]:
			for item in stage[field]:
				if item.x+item.get("w",0)>=count*48: return "Move or erase objects beyond the new end first."
	begin_edit()
	if count<old:
		for k in cells.keys():
			if coord(k).x>=count: cells.erase(k)
	else:
		for y in [13,14]:
			var edge=cells.get(key(Vector2i(old-1,y)),{})
			if edge.get("kind","")=="ground":
				for x in range(old,count): cells[key(Vector2i(x,y))]={"kind":"ground"}
	if stage.goal[0]>=count*48 or stage.length-stage.goal[0]<=144: stage.goal[0]=count*48-120
	stage.length=count*48;end_edit();return ""
func compile() -> Dictionary:
	var result=stage.duplicate(true);result.platforms=[]
	# Merge only equivalent adjacent cells. Moving groups keep one collision body;
	# crumble cells stay independent so stepping on one does not erase a whole bridge.
	for y in range(first_row(),ROWS):
		var x=0
		while x<columns():
			var data: Dictionary=cells.get(key(Vector2i(x,y)),{})
			if data.is_empty(): x+=1;continue
			var width=1
			while data.kind!="crumble" and x+width<columns() and same(cells.get(key(Vector2i(x+width,y)),{}),data): width+=1
			var p=data.duplicate(true);p.merge({"x":x*TILE,"y":y*TILE,"w":width*TILE,"h":TILE})
			result.platforms.append(p);x+=width
	result.checkpoints.sort_custom(func(a,b): return a[0]<b[0])
	return result
static func number(value: Variant) -> bool: return (value is int or value is float) and is_finite(float(value))
static func point(value: Variant) -> bool:
	return value is Array and value.size()==2 and number(value[0]) and number(value[1])
static func errors(s: Variant, check_playable: bool=false) -> PackedStringArray:
	var out=PackedStringArray()
	if not s is Dictionary: return PackedStringArray(["This file is not a Yearbound layout object."])
	if s.get("schema_version")!=1 or s.get("grid_size")!=48: return PackedStringArray(["Open a Yearbound layout made for the 48-pixel block grid."])
	for field in ["id","title","season","music"]:
		if not s.get(field) is String: return PackedStringArray(["Missing or invalid field: "+field])
	var calendar=JSON.parse_string(FileAccess.get_file_as_string("res://content/calendar.json"))
	var valid_date=false
	for day in calendar.days:
		if day.id==s.id: valid_date=true;break
	if not valid_date: out.append("Choose a valid calendar date (June–May, excluding 29 February).")
	if s.title.strip_edges().is_empty() or s.title.length()>80: out.append("Give this day a title of 1–80 characters.")
	if not s.season in SEASONS: out.append("Unknown seasonal theme.")
	if s.has("abilities"):
		if not s.abilities is Array: return PackedStringArray(["Abilities must be a list of known mechanic identifiers."])
		for id in s.abilities:
			if id!="charge_dash": out.append("Unknown player ability.")
	var music_paths=[]
	for id in JSON.parse_string(FileAccess.get_file_as_string("res://content/catalog.json")).stages:
		music_paths.append(JSON.parse_string(FileAccess.get_file_as_string("res://content/stages/"+id+".json")).music)
	if not s.music in music_paths: out.append("Choose one of the included music sketches.")
	if s.has("background") and (not s.background is String or not s.background.begins_with("res://art/") or ".." in s.background or not ResourceLoader.exists(s.background)): out.append("Unknown background asset.")
	if s.has("terrain_style") and not s.terrain_style in JSON.parse_string(FileAccess.get_file_as_string("res://content/terrain_styles.json")): out.append("Unknown terrain palette.")
	if s.has("ambience"):
		if not s.ambience is Dictionary: return PackedStringArray(["Invalid atmosphere settings."])
		if s.ambience.has("june_scene") and (not s.ambience.june_scene is String or not YBJuneScenery.scenes.has(s.ambience.june_scene)): out.append("Unknown June scene.")
		if s.ambience.has("haze") and (not s.ambience.haze is String or not Color.html_is_valid(s.ambience.haze)): out.append("Invalid atmosphere color.")
		for field in ["haze_strength","separation"]:
			if s.ambience.has(field) and (not number(s.ambience[field]) or s.ambience[field]<0 or s.ambience[field]>1): out.append("Atmosphere strength must be between zero and one.")
	if not number(s.get("length")) or s.length<1296 or s.length>MAX_COLUMNS*TILE or fmod(s.length,TILE)!=0: return PackedStringArray(["Length must be 27–2048 blocks."])
	for field in ["spawn","goal"]:
		if not point(s.get(field)): return PackedStringArray(["Missing or invalid "+field+" marker."])
	for field in ["platforms","motes","checkpoints","hazards","zones","decorations","signs"]:
		if not s.get(field) is Array or s[field].size()>16000: return PackedStringArray(["Invalid collection: "+field])
	for field in ["motes","checkpoints"]:
		for pos in s[field]:
			if not point(pos): return PackedStringArray(["Invalid position in "+field])
	if s.has("ground") and (not s.ground is Dictionary or not number(s.ground.get("y")) or s.ground.y!=624): return PackedStringArray(["Invalid base floor."])
	var top=s.get("world_top",0)
	if not number(top) or top>0 or top<MIN_TOP or fmod(top,48)!=0: return PackedStringArray(["Vertical bounds must follow the 48-pixel grid (0 to -3072)."] )
	var cell_count=0
	for p in s.platforms:
		if not p is Dictionary or not p.get("kind") in ["ground","wood","block","ice","moving","spring","crumble"]: return PackedStringArray(["Unknown block type."])
		for field in ["x","y","w","h"]:
			if not number(p.get(field)) or fmod(p[field],48)!=0: return PackedStringArray(["Terrain must align to the 48-pixel grid."])
		if p.x<0 or p.y<top or p.w<=0 or p.h<=0 or p.x+p.w>s.length or p.y+p.h>720: return PackedStringArray(["A terrain block is outside the stage bounds."])
		cell_count+=int(p.w*p.h/2304)
		if cell_count>16000: return PackedStringArray(["This layout exceeds 16,000 blocks."])
		if p.kind=="block" and not p.get("material") in ["stone","hay","log"]: out.append("Unknown block material.")
		if p.kind=="moving":
			if not p.get("axis") in ["x","y"] or not number(p.get("distance")) or not number(p.get("speed")): return PackedStringArray(["Invalid moving block settings."])
			if p.distance<=0 or p.distance>960 or p.speed<=0 or p.speed>6: out.append("Moving block settings are outside the supported range.")
		if p.kind=="spring" and (not number(p.get("power")) or p.power<100 or p.power>1500): out.append("Invalid spring strength.")
	for field in ["hazards","zones","decorations","signs"]:
		for obj in s[field]:
			if not obj is Dictionary: return PackedStringArray(["Invalid item in "+field])
			for name in ["x","y"]:
				if not number(obj.get(name)): return PackedStringArray(["Missing position in "+field])
			for name in ["w","h","r","speed","distance","phase","period","width","height","scale"]:
				if obj.has(name) and (not number(obj[name]) or absf(obj[name])>50000): return PackedStringArray(["Invalid numeric setting in "+field])
			for name in ["w","h","r","width","height","scale","period"]:
				if obj.has(name) and obj[name]<=0: return PackedStringArray(["Dimensions must be positive in "+field])
			if field=="hazards":
				if obj.get("direction","up") not in ["up","down","left","right"]: out.append("Unknown spike direction.")
				if not obj.get("type") in ["bramble","blade","thorn","icicle"]: out.append("Unknown hazard.")
				elif obj.type=="bramble" and (not obj.has("w") or not obj.has("h")): out.append("Bramble size is missing.")
				elif obj.type!="bramble" and not obj.has("r"): out.append("Hazard radius is missing.")
				elif obj.type=="icicle" and not obj.has("period"): out.append("Icicle timing is missing.")
			if field=="zones":
				if not obj.get("type") in ["water","wind","updraft","current"] or not obj.has("w") or not obj.has("h") or (obj.type!="water" and not point(obj.get("force"))): out.append("Invalid environmental zone.")
				if obj.has("swimmable") and (obj.type!="water" or not obj.swimmable is bool): out.append("Only water zones can have a boolean swimmable flag.")
			if field=="decorations":
				if not obj.get("type") in ["fence","hedge","flowers","flowerbed","tree","ivy","birdhouse","signpost","stone_wall","reeds","boulder","beehive"] + YBDayDecor.TYPES + YBMonthScenery.TYPES + YBJuneScenery.TYPES: out.append("Unknown decoration.")
				if obj.get("layer","back") not in ["back","front"]: out.append("Unknown decoration layer.")
				if obj.has("platform"): out.append("Use world positions for editor decorations.")
				if obj.has("season") and not obj.season in SEASONS: out.append("Unknown decoration season.")
			if field=="signs" and (not obj.get("text") is String or obj.text.length()>500): out.append("Invalid sign text.")
	if s.has("boss") and (not s.boss is Dictionary or not number(s.boss.get("duration")) or s.boss.duration!=105): out.append("This editor preserves the existing 105-second boss pattern only.")
	if not out.is_empty() or not check_playable: return out
	for pos in [s.spawn,s.goal]+s.checkpoints:
		if pos[0]<12 or pos[0]>s.length-12 or pos[1]<top+48 or pos[1]>720: out.append("A start, exit or checkpoint is outside the playable area.");continue
		var foot=Vector2(pos[0],pos[1]);var body=Rect2(foot-Vector2(12,42),Vector2(24,41))
		var supported=s.has("ground") and absf(s.ground.y-foot.y)<1
		for p in s.platforms:
			if Rect2(p.x,p.y,p.w,p.h).intersects(body): out.append("A start, exit or checkpoint is inside a solid block.");break
			if p.kind not in ["moving","spring","crumble"] and absf(p.y-foot.y)<1 and foot.x>=p.x+10 and foot.x<=p.x+p.w-10: supported=true
		if not supported: out.append("Place the start, exit and checkpoints in empty cells just above stable blocks.")
		for h in s.hazards:
			if h.type=="bramble" and body.intersects(Rect2(h.x,h.y,h.w,h.h)): out.append("Move a start, exit or checkpoint away from spikes.")
	return out

static func same(a: Variant, b: Variant) -> bool:
	if number(a) and number(b): return float(a)==float(b)
	if a is Dictionary and b is Dictionary:
		if a.size()!=b.size(): return false
		for k in a:
			if not b.has(k) or not same(a[k],b[k]): return false
		return true
	if a is Array and b is Array:
		if a.size()!=b.size(): return false
		for i in a.size():
			if not same(a[i],b[i]): return false
		return true
	return typeof(a)==typeof(b) and a==b
static func contains(items: Array, value: Variant) -> bool:
	for item in items:
		if same(item,value): return true
	return false

static func read_layout(path: String) -> Dictionary:
	var file=FileAccess.open(path,FileAccess.READ)
	if file==null: return {"error":"The layout could not be opened."}
	if file.get_length()>4*1024*1024: return {"error":"Layouts must be smaller than 4 MB."}
	var json=JSON.new();var code=json.parse(file.get_as_text())
	if code!=OK: return {"error":"Invalid JSON at line %d: %s" % [json.get_error_line(),json.get_error_message()]}
	var issues=errors(json.data)
	if not issues.is_empty(): return {"error":issues[0]}
	return {"stage":json.data}
static func write_layout(path: String, value: Dictionary) -> Error:
	var file=FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file==null: return FileAccess.get_open_error()
	file.store_string(JSON.stringify(value,"\t",true,true));file.flush()
	var result=file.get_error();file.close()
	if result!=OK: return result
	if FileAccess.file_exists(path):
		result=DirAccess.copy_absolute(path,path+".bak")
		if result!=OK: return result
	return DirAccess.rename_absolute(path+".tmp",path)
