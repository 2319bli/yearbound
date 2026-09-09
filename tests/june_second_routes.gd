extends SceneTree
var failures := 0
# Normal input traversal of the eight newly authored decoration routes.
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app)
	await physics_frame
	for id in ["06-09","06-10","06-11","06-12","06-13","06-14","06-16","06-17"]:
		app.start_stage(id)
		var w=app.world
		var flooded=w.spec.zones.any(func(z): return z.type=="current" and z.force[1]<-1000)
		var furthest=0.0
		var old_deaths=0
		var jumped_at=-1
		var launch_count=0
		var stalled=0
		Input.action_press("right")
		for i in 6000:
			await physics_frame
			if w.complete: break
			var p=w.player
			stalled=0 if p.position.x>furthest+1 else stalled+1
			furthest=maxf(furthest,p.position.x)
			if stalled>300 and p.position.x<float(w.spec.goal[0])-200:
				print("STALLED ",id," at=",p.position," velocity=",p.velocity," floor=",p.is_on_floor());break
			if p.position.x>float(w.spec.goal[0])-220:
				Input.action_release("right");Input.action_release("left")
				var dx=float(w.spec.goal[0])-p.position.x
				if absf(dx)>18: Input.action_press("right" if dx>0 else "left")
			if w.deaths>old_deaths:
				print(id," death at route progress ",furthest," / ",w.spec.length)
				old_deaths=w.deaths
				if old_deaths>18: break
			# Release at the apex so each short landing can receive a fresh press.
			if p.velocity.y > 0: Input.action_release("jump")
			if p.ability.charging and not p.is_on_floor() and flooded and jumped_at>=0 and i-jumped_at>=14:
				Input.action_release("ability");launch_count+=1
			elif p.ability.charging and not p.is_on_floor() and not flooded:
				for h in w.spec.hazards:
					# Save the release for the hazard, rather than spending the only
					# air launch on a preceding hay stack or sheltered ledge.
					if h.type=="bramble" and h.x-p.position.x<140 and h.x+h.w>p.position.x and p.position.y<h.y-18:
						Input.action_release("ability");launch_count+=1;break
			if p.is_on_floor() and w.respawn_delay<=0:
				var obstacle_ahead=false
				for h in w.spec.hazards:
					if h.type=="bramble" and h.x-p.position.x>100 and h.x-p.position.x<400 and h.y<p.position.y+80 and h.y+h.h>p.position.y-60:
						if p.ability.available(true): Input.action_press("ability")
				for obstacle in w.platforms:
					if obstacle.gone or obstacle.data.get("base_ground",false): continue
					var at=obstacle.body.position
					var dx=at.x-p.position.x-12
					if dx>0 and dx<102 and at.y<p.position.y-4 and at.y+float(obstacle.data.h)>p.position.y-42 and at.y>=p.position.y-112: obstacle_ahead=true
				for hazard in w.spec.hazards:
					if hazard.type=="bramble" and hazard.x-p.position.x<92 and hazard.x+hazard.w>p.position.x and hazard.y<p.position.y+80 and hazard.y+hazard.h>p.position.y-36: obstacle_ahead=true
				if obstacle_ahead: Input.action_press("jump");jumped_at=i
				for platform in w.platforms:
					var at=platform.body.position
					if absf(p.position.y-at.y)<5 and p.position.x>=at.x-12 and p.position.x<=at.x+float(platform.data.w)+12:
						if not w.spec.has("ground") and p.position.x>at.x+float(platform.data.w)-24:
							Input.action_press("jump")
						break
		Input.action_release("right");Input.action_release("left");Input.action_release("jump");Input.action_release("ability")
		print("ROUTE ",id," complete=",w.complete," farthest=",furthest," deaths=",w.deaths," dash_releases=",launch_count)
		if not w.complete: failures += 1
	root.remove_child(app);app.queue_free();await process_frame;await process_frame
	print("JUNE SECOND ROUTES TEST COMPLETE: ",failures," failures")
	call_deferred("quit",1 if failures else 0)
