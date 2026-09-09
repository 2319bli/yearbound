extends SceneTree
var failures=0
func _initialize() -> void:call_deferred("run")
func frames(n: int) -> void:
	for i in n:await physics_frame
func release() -> void:
	for action in YBControls.ACTIONS:Input.action_release(action)
func steer(p: YBPlayer, target: float) -> void:
	Input.action_release("left");Input.action_release("right")
	var control=clampf((target-p.position.x)/42-p.velocity.x/700,-1,1)
	if absf(control)>.09:Input.action_press("right" if control>0 else "left",absf(control))
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(4)
	app.start_stage("06-30");await frames(4);var w=app.world;var b=w.june_boss
	w.sound.connect(func(id):
		if id=="death":print("BOSS DEATH phase=",b.phase," at=",w.player.position," time=",b.phase_time," wall=",b.chase_wall()," shots=",w.projectiles))
	# Enter each arena once, then survive its full duration using actual inputs and attacks.
	for phase in [0,1,3,4]:
		w.respawn_delay=0;w.player.active=true;w.player.visible=true;b.enter(phase);var region=b.data();var start=float(region.from_x)
		var platforms=w.platforms.filter(func(v):return v.data.kind=="wood" and v.data.x>start and v.data.x<region.to_x)
		var perch=platforms[1];var center=perch.body.position.x+perch.data.w*.5
		w.player.reset_at(Vector2(center,perch.body.position.y));await frames(4);var deaths=w.deaths
		for i in 3000:
			if b.cleared or b.defeated:break
			var low=perch.body.position.x+28;var high=perch.body.position.x+perch.data.w-28
			var target=clampf(w.player.position.x,low,high);var best=-INF
			for candidate in [low,lerpf(low,high,.25),center,lerpf(low,high,.75),high]:
				var margin=300.0
				for shot in w.projectiles:
					if shot.kind!="rain" or shot.pos.y>perch.body.position.y+40:continue
					var landing=shot.pos.x+shot.vel.x*maxf(0,(perch.body.position.y-21-shot.pos.y)/shot.vel.y)
					var impact=maxf(0,shot.delay)+maxf(0,(perch.body.position.y-21-shot.pos.y)/shot.vel.y)
					for offset in ([-.09,0,.09] if phase==4 else [0]):
						var future=move_toward(w.player.position.x,candidate,maxf(0,impact+offset-.05)*340) if phase==4 else candidate
						margin=minf(margin,absf(future-landing))
				var score=margin-absf(candidate-w.player.position.x)*.12
				if score>best:best=score;target=candidate
			steer(w.player,target);await frames(1)
			if w.deaths>deaths:break
		release();var ok=w.deaths==deaths and (b.cleared or b.defeated)
		print("BOSS SURVIVAL ",phase+1," completed=",ok," deaths=",w.deaths-deaths)
		if not ok:failures+=1
	w.respawn_delay=0;w.player.active=true;w.player.visible=true;b.enter(2);w.player.reset_at(w.checkpoint);await frames(4);var deaths=w.deaths
	var jump_wait=0
	for tick in 1800:
		if b.phase==3 or w.deaths>deaths:break
		Input.action_press("right");jump_wait=maxi(0,jump_wait-1)
		if w.player.is_on_floor() and jump_wait==0:
			Input.action_release("jump");var danger=false
			for platform in w.platforms:
				var rect=Rect2(platform.body.position,Vector2(platform.data.w,platform.data.h))
				if rect.position.x>w.player.position.x and rect.position.x<w.player.position.x+112 and rect.position.y<w.player.position.y-8 and rect.position.y>=w.player.position.y-100:danger=true
			for h in w.spec.hazards:
				if h.type=="bramble" and h.x>w.player.position.x and h.x<w.player.position.x+85 and h.y>w.player.position.y-30 and h.y<w.player.position.y+100:danger=true
			if danger:Input.action_press("jump");jump_wait=22
		if w.player.velocity.y>0:Input.action_release("jump")
		await frames(1)
	var ok=b.phase==3 and w.deaths==deaths
	print("BOSS CHASE completed=",ok," deaths=",w.deaths-deaths)
	if not ok:failures+=1
	release();root.remove_child(app);app.queue_free();await frames(3)
	print("JUNE BOSS ROUTES TEST COMPLETE: ",failures," failures");quit(1 if failures else 0)
