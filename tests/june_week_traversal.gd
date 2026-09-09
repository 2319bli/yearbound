extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app)
	await physics_frame
	for id in ["06-02","06-03","06-04","06-05","06-06","06-07","06-08"]:
		app.start_stage(id)
		var w=app.world
		var furthest=0.0
		var old_deaths=0
		Input.action_press("right")
		for i in 18000:
			await physics_frame
			if w.complete: break
			var p=w.player
			furthest=maxf(furthest,p.position.x)
			if absf(p.position.x-float(w.spec.goal[0]))<35: Input.action_release("right")
			if w.deaths>old_deaths:
				print(id," death at route progress ",furthest," / ",w.spec.length)
				old_deaths=w.deaths
				if old_deaths>18: break
			# Release at the apex so each short landing can receive a fresh press.
			if p.velocity.y > 0: Input.action_release("jump")
			if p.is_on_floor() and w.respawn_delay<=0:
				var obstacle_ahead=false
				for obstacle in w.platforms:
					if obstacle.gone or obstacle.data.get("base_ground",false): continue
					var at=obstacle.body.position
					var dx=at.x-p.position.x-12
					if dx>0 and dx<102 and at.y<p.position.y-4 and at.y+float(obstacle.data.h)>p.position.y-42 and at.y>=p.position.y-112: obstacle_ahead=true
				for hazard in w.spec.hazards:
					if hazard.type=="bramble" and hazard.x-p.position.x<92 and hazard.x+hazard.w>p.position.x and hazard.y<p.position.y+1 and hazard.y+hazard.h>p.position.y-36: obstacle_ahead=true
				if obstacle_ahead: Input.action_press("jump")
				for platform in w.platforms:
					var at=platform.body.position
					if absf(p.position.y-at.y)<5 and p.position.x>=at.x-12 and p.position.x<=at.x+float(platform.data.w)+12:
						if not w.spec.has("ground") and p.position.x>at.x+float(platform.data.w)-24:
							Input.action_press("jump")
						break
		Input.action_release("right");Input.action_release("jump")
		print("ROUTE ",id," complete=",w.complete," farthest=",furthest," deaths=",w.deaths)
		if not w.complete: failures += 1
	root.remove_child(app);app.queue_free();await process_frame;await process_frame
	print("TRAVERSAL TEST COMPLETE: ",failures," failures")
	call_deferred("quit",1 if failures else 0)
