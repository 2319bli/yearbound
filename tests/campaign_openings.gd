extends SceneTree
var failures := 0
# Original opening routes remain a warmup. The extended vertical courses are tested in expanded_routes.gd.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app)
	await physics_frame
	var only=OS.get_environment("YEARBOUND_ROUTE_IDS").split(",",false)
	for id in app.stage_order:
		if not only.is_empty() and id not in only: continue
		if id in ["06-30","11-19"]: continue
		for action in YBControls.ACTIONS: Input.action_release(action)
		var use_dash=id not in ["06-01","06-02","06-04","06-05","06-06","06-07","06-08","06-15","10-12","01-18","03-09"]
		app.start_stage(id)
		var w=app.world
		var flooded=w.spec.zones.any(func(z): return z.type=="current" and z.force[1]<-1000)
		var furthest=0.0
		var old_deaths=0
		var jumped_at=-1
		var launch_count=0
		Input.action_press("right")
		for i in 18000:
			await physics_frame
			if w.player.position.x>=w.spec.challenge.extension_start+24: break
			var p=w.player
			furthest=maxf(furthest,p.position.x)
			
			if w.deaths>old_deaths:
				print(id," death at route progress ",furthest," / ",w.spec.length)
				old_deaths=w.deaths
				Input.action_release("jump");Input.action_release("ability");Input.action_press("right")
				if old_deaths>18: break
			# Release at the apex so each short landing can receive a fresh press.
			if p.velocity.y > 0: Input.action_release("jump")
			if use_dash and p.ability.charging and not p.is_on_floor() and flooded and jumped_at>=0 and i-jumped_at>=14:
				Input.action_release("ability");launch_count+=1
			elif use_dash and p.ability.charging and not p.is_on_floor() and not flooded:
				for h in w.spec.hazards:
					# Save the release for the hazard, rather than spending the only
					# air launch on a preceding hay stack or sheltered ledge.
					if h.type=="bramble" and h.x-p.position.x<140 and h.x+h.w>p.position.x and p.position.y<h.y-18:
						Input.action_release("ability");launch_count+=1;break
			if p.is_on_floor() and w.respawn_delay<=0:
				var obstacle_ahead=false
				for h in w.spec.hazards:
					if h.type=="bramble" and h.x-p.position.x>100 and h.x-p.position.x<400 and h.y<p.position.y+80 and h.y+h.h>p.position.y-60:
						if use_dash and p.ability.available(true): Input.action_press("ability")
				for obstacle in w.platforms:
					if obstacle.gone or obstacle.data.get("base_ground",false): continue
					var at=obstacle.body.position
					var dx=at.x-p.position.x-12
					if dx>0 and dx<102 and at.y<p.position.y-4 and at.y+float(obstacle.data.h)>p.position.y-42 and at.y>=p.position.y-112: obstacle_ahead=true
				for hazard in w.spec.hazards:
					if hazard.type=="bramble" and hazard.x-p.position.x<92 and hazard.x+hazard.w>p.position.x and hazard.y<p.position.y+(80 if use_dash else 1) and hazard.y+hazard.h>p.position.y-36: obstacle_ahead=true
				if obstacle_ahead: Input.action_press("jump");jumped_at=i
				for platform in w.platforms:
					var at=platform.body.position
					if absf(p.position.y-at.y)<5 and p.position.x>=at.x-12 and p.position.x<=at.x+float(platform.data.w)+12:
						if not w.spec.has("ground") and p.position.x>at.x+float(platform.data.w)-24:
							Input.action_press("jump")
						break
		Input.action_release("right");Input.action_release("jump");Input.action_release("ability")
		furthest=maxf(furthest,w.player.position.x)
		print("ROUTE ",id," reached_new_route=",furthest>=w.spec.challenge.extension_start+24," farthest=",furthest," deaths=",w.deaths," dash_releases=",launch_count)
		if furthest<w.spec.challenge.extension_start+24: failures += 1
	root.remove_child(app);app.queue_free();await process_frame;await process_frame
	print("CAMPAIGN OPENINGS TEST COMPLETE: ",failures," failures")
	call_deferred("quit",1 if failures else 0)
