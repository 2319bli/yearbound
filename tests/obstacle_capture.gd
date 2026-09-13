extends "res://tests/map_scenery_capture.gd"
func run() -> void:
	DirAccess.make_dir_recursive_absolute(OS.get_environment("YEARBOUND_CAPTURE_DIR"))
	app=load("res://main.tscn").instantiate();root.add_child(app);await frames(5);app.transition=0
	await shot("title")
	app.screen="calendar";app.month_index=1;app.selected="07-02";await shot("calendar-july")
	app.month_index=0;app.selected="06-12";await shot("calendar-orchard")
	var only=OS.get_environment("YEARBOUND_CAPTURE_IDS").split(",",false)
	for id in app.stage_order:
		if not only.is_empty() and id not in only:continue
		app.start_stage(id);await frames(3);var w=app.world
		w.set_running(false);app.transition=0;app.intro=0;app.toast_time=0
		await shot(id+"-opening")
		for index in w.spec.journey_regions.size():
			var region=w.spec.journey_regions[index]
			var machines=w.spec.hazards.filter(func(h):return h.type=="mechanism" and h.x>=region.x and h.x<region.x+region.w)
			if machines.is_empty():continue
			var h=machines[0];var at=Vector2(h.x-130,h.y+144)
			var route=w.spec.challenge.route.filter(func(n):return n.get("obstacle_id","")==h.id)
			if not route.is_empty():at=Vector2(route[0].at[0]-245,route[0].at[1])
			w.player.position=at;w.camera_x=clampf(h.x-520,0,w.spec.length-1280);w.camera_y=clampf(at.y-460,w.spec.world_top,0);w.camera.position=Vector2(w.camera_x+640,w.camera_y+360)
			w.age=float(h.period)-float(h.phase)-.45
			await shot(id+"-mechanism-"+str(index+1))
	root.remove_child(app);app.queue_free();await frames(3)
	print("OBSTACLE CAPTURE COMPLETE");quit()
