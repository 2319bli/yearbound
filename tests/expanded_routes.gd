extends SceneTree
var failures=0
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await physics_frame
func release() -> void:
	for action in YBControls.ACTIONS: Input.action_release(action)
func steer(p: YBPlayer, target: float) -> void:
	Input.action_release("left");Input.action_release("right")
	var error=target-p.position.x
	var control=clampf(error/60-p.velocity.x/800,-1,1)
	if absf(control)>.1: Input.action_press("right" if control>0 else "left",absf(control))
func hop(w: YBWorld, target: Vector2, source_kind: String) -> bool:
	var p=w.player;release()
	for i in 35:
		if p.is_on_floor(): break
		await frames(1)
	var deaths=w.deaths;var initial=p.position;var delta=target-initial
	Input.action_press("ability");await frames(30 if source_kind=="crumble" else 48)
	var charged=p.ability.charge_ratio
	var diagonal=absf(delta.x)>300 or source_kind=="crumble"
	if diagonal: Input.action_press("right" if delta.x>0 else "left")
	Input.action_press("jump");await frames(9)
	Input.action_press("aim_up")
	if diagonal: Input.action_press("right" if delta.x>0 else "left")
	Input.action_release("ability");await frames(1);Input.action_release("aim_up")
	var launched=p.ability.dashing;var peak=p.position.y
	for i in 210:
		peak=minf(peak,p.position.y)
		if w.deaths>deaths:
			print("HOP TRACE initial=",initial," charge=",charged," launched=",launched," peak=",peak," target=",target," kind=",source_kind);release();return false
		if p.position.y<target.y-12 or delta.y>0 or (p.is_on_floor() and absf(p.position.y-target.y)<5): steer(p,target.x)
		else: steer(p,target.x-signf(delta.x)*110)
		if p.velocity.y>0: Input.action_release("jump")
		if p.is_on_floor() and absf(p.position.y-target.y)<5 and absf(p.position.x-target.x)<24:
			release();return true
		await frames(1)
	release();return false
func swim(w: YBWorld, target: Vector2) -> bool:
	var deaths=w.deaths
	for i in 420:
		var delta=target-w.player.position
		if delta.length()<20: release();return true
		release()
		if absf(delta.x)>5: Input.action_press("right" if delta.x>0 else "left",clampf(absf(delta.x)/70,.15,1))
		if absf(delta.y)>5: Input.action_press("aim_down" if delta.y>0 else "aim_up",clampf(absf(delta.y)/70,.15,1))
		await frames(1)
		if w.deaths>deaths:return false
	return false
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(3)
	var only=OS.get_environment("YEARBOUND_ROUTE_IDS").split(",",false)
	for id in app.stage_order:
		if not only.is_empty() and id not in only: continue
		app.start_stage(id);await frames(3);var w=app.world;var route=w.spec.challenge.route
		# Start at the first new checkpoint. All subsequent travel uses normal input.
		var first=route[0].at
		var index=w.spec.checkpoints.find(first)
		w.restore({"checkpoint_index":index});await frames(5)
		var count=1
		for i in range(1,route.size()):
			var target=Vector2(route[i].at[0],route[i].at[1])
			var ok=false
			if id=="11-19":
				# Rise away from the old deck before crossing a sharp platform edge.
				var high=minf(target.y-75,w.player.position.y-60)
				ok=await swim(w,Vector2(w.player.position.x,high))
				if ok: ok=await swim(w,Vector2(target.x,high))
				if ok: ok=await swim(w,target-Vector2(0,75))
			else: ok=await hop(w,target,route[i-1].kind)
			if not ok:
				print("FAILED HOP ",id," index=",i," from=",route[i-1].at," target=",target," at=",w.player.position," v=",w.player.velocity," deaths=",w.deaths);break
			count+=1
		release()
		var reached_exit=false
		if count==route.size():
			if id=="11-19":
				await swim(w,Vector2(w.spec.goal[0],w.spec.goal[1]-5));reached_exit=w.complete
			else:
				Input.action_press("right")
				for i in 180:
					await frames(1)
					if w.complete or w.boss_active: reached_exit=true;break
			release()
		print("ROUTE ",id," landings=",count,"/",route.size()," reached_exit=",reached_exit," deaths=",w.deaths)
		if count!=route.size() or not reached_exit: failures+=1
	root.remove_child(app);app.queue_free();await frames(3)
	print("EXPANDED ROUTES TEST COMPLETE: ",failures," failures");quit(1 if failures else 0)
