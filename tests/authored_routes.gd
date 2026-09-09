extends SceneTree
var failures=0
var last_trace=""
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await physics_frame
func release() -> void:
	for action in YBControls.ACTIONS: Input.action_release(action)
func steer(p: YBPlayer, target: float) -> void:
	Input.action_release("left");Input.action_release("right")
	var control=clampf((target-p.position.x)/42-p.velocity.x/700,-1,1)
	if absf(control)>.09: Input.action_press("right" if control>0 else "left",absf(control))
func standing_kind(w: YBWorld) -> String:
	for platform in w.platforms:
		var at=platform.body.position;var d=platform.data
		if not platform.gone and absf(w.player.position.y-at.y)<5 and w.player.position.x>at.x-8 and w.player.position.x<at.x+d.w+8 and not d.get("base_ground",false): return d.kind
	return "ground"
func launch_edge(w: YBWorld, target: Vector2) -> float:
	var p=w.player;var direction=signf(target.x-p.position.x);var edge=p.position.x
	for step in 24:
		var x=p.position.x+direction*(step*12+12)
		if absf(x-p.position.x)>absf(target.x-p.position.x)-36: break
		var supported=false;var blocked=false
		for platform in w.platforms:
			if platform.gone:continue
			var r=Rect2(platform.body.position,Vector2(platform.data.w,platform.data.h))
			if x>=r.position.x+2 and x<=r.end.x-2 and absf(p.position.y-r.position.y)<5:supported=true
			if r.intersects(Rect2(x-12,p.position.y-38,24,36)):blocked=true
			if target.y<p.position.y-8 and r.intersects(Rect2(x-18,target.y-42,36,p.position.y-target.y+40)):blocked=true
		for h in w.spec.hazards:
			if h.type=="bramble" and Rect2(h.x,h.y,h.w,h.h).intersects(Rect2(x-32,p.position.y-38,64,38)):blocked=true
		if not supported or blocked:break
		edge=x
	return edge
func arrive(w: YBWorld, target: Vector2, ticks: int=220, allow_air: bool=false) -> bool:
	var deaths=w.deaths
	for i in ticks:
		if w.complete or w.boss_active:return true
		if w.deaths>deaths:return false
		if absf(w.player.position.x-target.x)<21 and absf(w.player.position.y-target.y)<8 and (w.player.is_on_floor() or allow_air):release();return true
		steer(w.player,target.x)
		if w.player.velocity.y>0:Input.action_release("jump")
		await frames(1)
	return false
func leap(w: YBWorld, target: Vector2, mode: String) -> bool:
	var p=w.player;var deaths=w.deaths;release()
	for i in 35:
		if p.is_on_floor() or p.spring_flight:break
		await frames(1)
	if p.spring_flight:
		return await arrive(w,target,200,mode=="bounce")
	var initial=p.position;var edge=launch_edge(w,target)
	var charged=mode in ["dash","short","roof_jump"] or mode in ["jump","bounce"] and (absf(target.x-edge)>245 or target.y<p.position.y-110)
	if charged:Input.action_press("ability")
	var duration=5 if mode=="short" else (20 if mode=="roof_jump" else (32 if standing_kind(w)=="crumble" else 48))
	for i in (duration if charged else 12):
		steer(p,edge);await frames(1)
		if w.deaths>deaths:return false
		if not charged and absf(p.position.x-edge)<12:break
	var delta=target-p.position
	var clearance=target.x-signf(delta.x)*100;var riser=false
	for platform in w.platforms:
		var at=platform.body.position;var d=platform.data
		if absf(at.y-target.y)<5 and target.x>=at.x and target.x<=at.x+d.w:
			clearance=at.x-22 if delta.x>0 else at.x+d.w+22;riser=d.h>48 and at.y+d.h>=p.position.y-8;break
	var diagonal=absf(delta.x)>285 and delta.y>-280
	if delta.y< -180 and (mode=="roof_jump" or absf(clearance-p.position.x)<200 and riser):diagonal=false
	var leave_roof=false
	for hazard in w.spec.hazards:
		if hazard.type=="bramble" and hazard.get("direction","")=="down" and hazard.x<p.position.x+14 and hazard.x+hazard.w>p.position.x-14 and hazard.y<p.position.y-80 and hazard.y>p.position.y-400:leave_roof=true
	var horizontal=mode=="short" or mode=="roof_jump" and delta.y>0
	Input.action_press("jump")
	if diagonal or not charged or horizontal or leave_roof:Input.action_press("right" if delta.x>0 else "left")
	await frames(6 if mode=="short" else 9)
	if charged:
		if not horizontal:Input.action_press("aim_up")
		if diagonal or horizontal:Input.action_press("right" if delta.x>0 else "left")
		else:Input.action_release("left");Input.action_release("right")
		Input.action_release("ability");await frames(1);Input.action_release("aim_up")
	if mode=="short":Input.action_release("jump")
	last_trace="from="+str(initial)+" edge="+str(edge)+" mode="+mode+" launch="+str(p.velocity)
	for i in 240:
		if w.complete or w.boss_active:return true
		if w.deaths>deaths:release();return false
		if mode=="bounce" and p.spring_flight and absf(p.position.x-target.x)<80:release();return true
		if p.is_on_floor() and absf(p.position.y-target.y)<5 and absf(p.position.x-target.x)<22:release();return true
		if p.position.y<target.y-(32 if charged else 3) or delta.y>0 or p.is_on_floor() and absf(p.position.y-target.y)<5:steer(p,target.x)
		else:steer(p,clearance)
		if p.velocity.y>0:Input.action_release("jump")
		await frames(1)
	release();return false
func swimming(w: YBWorld, target: Vector2) -> bool:
	var deaths=w.deaths
	for i in 900:
		var delta=target-w.player.position
		if delta.length()<18:release();return true
		release()
		if absf(delta.x)>4:Input.action_press("right" if delta.x>0 else "left",clampf(absf(delta.x)/70,.12,1))
		if absf(delta.y)>4:Input.action_press("aim_down" if delta.y>0 else "aim_up",clampf(absf(delta.y)/70,.12,1))
		await frames(1)
		if w.deaths>deaths:return false
	return false
func move(w: YBWorld, node: Dictionary) -> bool:
	var target=Vector2(node.at[0],node.at[1]);var p=w.player;var deaths=w.deaths;var action=str(node.action);release()
	await frames(1)
	if p.swimming.submerged:return await swimming(w,target if action=="swim" else target-Vector2(0,50))
	if action=="swim":return await swimming(w,target)
	if action=="start":return true
	if action in ["walk","skate"]:return await arrive(w,target,320)
	if action=="boss":return await arrive(w,target,180)
	if action=="board":
		var platform=w.platforms.filter(func(v):return v.data.get("track_id","")==node.track_id)[0]
		if not await arrive(w,Vector2(target.x-platform.data.w*.5-22,target.y),160):return false
		for i in 900:
			var at=platform.body.position+Vector2(platform.data.w*.5,0)
			if absf(at.x-target.x)<24 and absf(at.y-target.y)<10 and YBPlatformMotion.offset(platform.data,w.age+.55).length()<24:break
			steer(p,p.position.x);await frames(1)
		await frames(1)
		Input.action_press("jump")
		for i in 220:
			var at=platform.body.position+Vector2(platform.data.w*.5,0);steer(p,at.x)
			if p.velocity.y>0:Input.action_release("jump")
			if p.is_on_floor() and absf(p.position.y-at.y)<5 and absf(p.position.x-at.x)<platform.data.w*.5-12:release();return true
			if w.deaths>deaths:return false
			await frames(1)
		return false
	if action=="ride":
		var platform=w.platforms.filter(func(v):return v.data.get("track_id","")==node.track_id)[0]
		for i in 1300:
			if OS.get_environment("YEARBOUND_TRACE_RIDE")=="1" and i%10==0:print("RIDE ",i," target=",target," player=",p.position," v=",p.velocity," platform=",platform.body.position," floor=",p.is_on_floor())
			var at=platform.body.position+Vector2(platform.data.w*.5,0);steer(p,at.x)
			if absf(at.y-target.y)<28 and target.x-at.x<220:release();return await leap(w,target,"jump")
			if w.deaths>deaths:return false
			await frames(1)
		return false
	if action=="flow_enter":
		Input.action_press("jump")
		for i in 180:
			steer(p,target.x)
			if absf(p.position.x-target.x)<35:release();return true
			if w.deaths>deaths:return false
			await frames(1)
		return false
	if action=="flow_exit":
		var leaving=false
		for i in 800:
			if OS.get_environment("YEARBOUND_TRACE_FLOW")=="1" and i%15==0:print("FLOW ",i," at=",p.position," velocity=",p.velocity," wind=",p.wind," ground=",p.is_on_floor())
			if p.position.y<target.y-120:leaving=true
			steer(p,target.x if leaving else float(node.shaft_x))
			if p.is_on_floor() and absf(p.position.y-target.y)<5 and absf(p.position.x-target.x)<30:release();return true
			if w.deaths>deaths:return false
			await frames(1)
		return false
	if action=="pendulum":
		var h=w.spec.hazards.filter(func(v):return absf(v.x-float(node.gate_x))<1)[0]
		for i in 600:
			if sin(w.age*float(h.speed)+float(h.phase))<-.6:break
			await frames(1)
		return await arrive(w,target,180)
	if action in ["timed","weather"]:
		var h=w.spec.hazards.filter(func(v):return absf(v.x-float(node.gate_x))<1)[0]
		for i in 600:
			var phase=YBStageHazards.cycle(h,w.age)
			if (action=="timed" and phase<.7) or (action=="weather" and phase>2.6 and phase<3.2):break
			await frames(1)
		return await arrive(w,target,160)
	if action=="drop":
		var ceiling=-9999.0
		for platform in w.platforms:
			var at=platform.body.position;var size=Vector2(platform.data.w,platform.data.h)
			if target.x>at.x and target.x<at.x+size.x and at.y+size.y<target.y-70 and at.y+size.y>target.y-400:ceiling=maxf(ceiling,at.y+size.y+24)
		if p.position.y<ceiling+48:
			for i in 100:
				steer(p,target.x)
				if not p.is_on_floor() and not p.ability.charging:Input.action_press("ability")
				if p.position.y>ceiling+50:break
				if w.deaths>deaths:return false
				await frames(1)
			Input.action_press("right" if target.x>p.position.x else "left");Input.action_release("ability");await frames(1)
			return await arrive(w,target,200)
		var floor_gap=false
		for h in w.spec.hazards:
			if h.type=="bramble" and h.y<target.y and h.y>p.position.y and h.x>p.position.x and h.x<target.x:floor_gap=true
		if absf(target.x-p.position.x)<280 or absf(target.x-launch_edge(w,target))<210:
			return await leap(w,target,"jump") if floor_gap else await arrive(w,target,180)
		return await leap(w,target,"dash")
	if action=="spring_land":
		if p.spring_flight:
			Input.action_press("ability")
			for i in 240:
				if w.complete or w.boss_active:return true
				if OS.get_environment("YEARBOUND_TRACE_SPRING")=="1" and i%15==0:print("SPRING ",i," target=",target," at=",p.position," velocity=",p.velocity," charge=",p.ability.charge_ratio," dashing=",p.ability.dashing)
				Input.action_release("aim_up")
				steer(p,target.x)
				if p.ability.charging and absf(target.x-p.position.x)>100 and p.velocity.y>-420 and (p.ability.charge_ratio>=.68 or absf(target.x-p.position.x)<400):
					Input.action_press("right" if target.x>p.position.x else "left")
					if p.position.y>target.y-35 or absf(target.x-p.position.x)>380 and p.position.y>target.y-200:Input.action_press("aim_up")
					Input.action_release("ability")
				if p.is_on_floor() and absf(p.position.y-target.y)<5 and absf(p.position.x-target.x)<25:release();return true
				if w.deaths>deaths:return false
				await frames(1)
			return false
		return await leap(w,target,"dash")
	var ok=await leap(w,target,action)
	if not ok and w.deaths==deaths and action in ["jump","bounce"]:ok=await leap(w,target,"dash")
	return ok
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(3)
	var only=OS.get_environment("YEARBOUND_ROUTE_IDS").split(",",false)
	for id in app.stage_order:
		if not only.is_empty() and id not in only:continue
		app.start_stage(id);await frames(5);var w=app.world
		if w.june_boss:
			print("ROUTE ",id," uses the dedicated five-arena boss suite");continue
		var route=w.spec.challenge.route;var count=0
		# One continuous attempt from the entrance. The script never relocates the player.
		for node in route:
			if not await move(w,node):
				print("FAILED ",id," node=",count," action=",node.action," target=",node.at," at=",w.player.position," velocity=",w.player.velocity," deaths=",w.deaths," ",last_trace);break
			count+=1
		release();var completed=false
		if count==route.size():
			if w.boss_active:pass
			elif id=="11-19":await swimming(w,Vector2(w.spec.goal[0],w.spec.goal[1]-5))
			else:await arrive(w,Vector2(w.spec.goal[0],w.spec.goal[1]),240)
			completed=w.complete or w.boss_active
		print("ROUTE ",id," actions=",count,"/",route.size()," completed=",completed," deaths=",w.deaths)
		if not completed or w.deaths:failures+=1
	root.remove_child(app);app.queue_free();await frames(3)
	print("AUTHORED ROUTES TEST COMPLETE: ",failures," failures");quit(1 if failures else 0)
