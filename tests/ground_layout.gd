extends SceneTree
var failures := 0
func _initialize() -> void: call_deferred("run")
func frames(count: int) -> void:
	for i in count: await physics_frame
func check(ok: bool, message: String) -> void:
	if ok: print("PASS: ",message)
	else: failures+=1;push_error(message)
func probe(parent: Node2D, tint: Color) -> Polygon2D:
	var shape=Polygon2D.new();shape.color=tint
	shape.polygon=PackedVector2Array([Vector2(-20,-20),Vector2(20,-20),Vector2(20,20),Vector2(-20,20)])
	parent.add_child(shape);shape.global_position=Vector2(400,300);shape.visible=false
	return shape
func rendered_layers(app: Node2D) -> void:
	app.start_stage("06-01");await frames(3)
	app.screen="playing";app.transition=0;app.intro=0;app.world.set_running(false)
	var w=app.world;w.camera_x=0;w.camera.position=Vector2(640,360)
	var nodes=[probe(w.render_layers.scenery,Color.GREEN),probe(w.render_layers.terrain,Color.RED),probe(w.player,Color.BLUE),probe(w.render_layers.hazards,Color.YELLOW),probe(w.render_layers.foreground,Color.MAGENTA),probe(app.overlay,Color.CYAN)]
	var expected=[Color.GREEN,Color.RED,Color.BLUE,Color.YELLOW,Color.MAGENTA,Color.CYAN]
	var labels=["scenery pass is visible","terrain occludes scenery","player occludes terrain and back props","hazards remain visible over the actor","foreground pass has independent depth","UI stays above the complete pixel world"]
	for i in nodes.size():
		nodes[i].visible=true
		await process_frame;await process_frame
		RenderingServer.force_draw();RenderingServer.force_sync()
		var capture=root.get_texture().get_image()
		var pixel=capture.get_pixel(int(capture.get_width()*400.0/1280),int(capture.get_height()*300.0/720))
		check(Vector3(pixel.r,pixel.g,pixel.b).distance_to(Vector3(expected[i].r,expected[i].g,expected[i].b))<0.05,labels[i])
	for node in nodes: node.queue_free()
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(3)
	for id in app.stage_order:
		app.start_stage(id);await frames(5)
		var w=app.world
		var continuous=true
		var excluded: Array[RID]=[w.player.get_rid()]
		for platform in w.platforms:
			if not platform.data.get("base_ground",false): excluded.append(platform.body.get_rid())
		for x in range(10,int(w.spec.length)-10,137):
			var query=PhysicsRayQueryParameters2D.create(Vector2(x,w.spec.ground.y-1),Vector2(x,w.spec.ground.y+5))
			query.exclude=excluded
			var hit=w.get_world_2d().direct_space_state.intersect_ray(query)
			if hit.is_empty() or absf(hit.position.y-float(w.spec.ground.y))>0.5:
				continuous=false;print("FLOOR SAMPLE ",id," x=",x," hit=",hit)
		check(continuous,id+" has continuous collision at one flat ground height")
		var old_run={"checkpoint_index":0,"collected":[0],"elapsed":12.0,"deaths":2}
		w.restore(old_run);await frames(3)
		check(absf(w.player.position.y-float(w.spec.ground.y))<2 or w.player.swimming.submerged,id+" legacy checkpoint resumes on the floor or in physical water")
		check(w.elapsed>=12 and w.deaths==2,id+" resume preserves time and death records")
	app.start_stage("06-01");await frames(3)
	var w=app.world
	var hazard=w.spec.hazards[0]
	w.player.reset_at(Vector2(hazard.x+hazard.w/2,hazard.y-2));w.player.velocity.y=-100
	await frames(2)
	check(w.deaths==0,"jumping above bramble tips is safe")
	w.player.reset_at(Vector2(hazard.x+hazard.w/2,w.spec.ground.y));await frames(3)
	check(w.deaths==1,"walking into brambles triggers one checkpoint retry")
	if DisplayServer.get_name()!="headless": await rendered_layers(app)
	root.remove_child(app);app.queue_free();await frames(3)
	print("GROUND/LAYER TEST COMPLETE: ",failures," failures")
	call_deferred("quit",1 if failures else 0)
