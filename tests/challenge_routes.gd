extends "res://tests/authored_routes.gd"
## One continuous, unassisted attempt per challenge, from its real entrance.
## All motion uses input actions, all hazards/physics remain active. No relocation.
func run() -> void:
	var app=load("res://main.tscn").instantiate();root.add_child(app);await frames(3)
	var only=OS.get_environment("YEARBOUND_ROUTE_IDS").split(",",false)
	var results=[]
	for id in app.challenge_order:
		if not only.is_empty() and id not in only:continue
		app.start_stage(id);await frames(5);var w=app.world;var count=0
		for node in w.spec.challenge.route:
			if not await move(w,node):
				print("FAILED ",id," node=",count," action=",node.action," target=",node.at," at=",w.player.position," velocity=",w.player.velocity," deaths=",w.deaths," ",last_trace);break
			count+=1
		release()
		if count==w.spec.challenge.route.size() and not w.complete:
			if w.player.swimming.submerged:await swimming(w,Vector2(w.spec.goal[0],w.spec.goal[1]))
			else:await arrive(w,Vector2(w.spec.goal[0],w.spec.goal[1]),240)
		var passed=w.complete and w.deaths==0
		results.append({"id":id,"passed":passed,"deaths":w.deaths,"completed":w.complete,"actions":count,"total_actions":w.spec.challenge.route.size(),"elapsed":w.elapsed})
		print("ROUTE ",id," actions=",count,"/",w.spec.challenge.route.size()," completed=",w.complete," deaths=",w.deaths)
		if not passed:failures+=1
	var report=FileAccess.open(OS.get_environment("YEARBOUND_SAVE_DIR").path_join("challenge-route-results.json"),FileAccess.WRITE)
	report.store_string(JSON.stringify(results,"\t"));report.close()
	root.remove_child(app);app.queue_free();await frames(3)
	print("CHALLENGE ROUTES TEST COMPLETE: ",failures," failures");quit(1 if failures else 0)
