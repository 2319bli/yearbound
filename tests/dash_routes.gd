extends SceneTree
var failures=0
var app: Node2D
func _initialize() -> void: call_deferred("run")
func frames(n: int) -> void:
	for i in n: await physics_frame
func release() -> void:
	for action in YBControls.ACTIONS: Input.action_release(action)
func prepare(index: int, offset: Vector2) -> void:
	release();app.lab_station(index);await frames(3)
	app.world.player.reset_at(Vector2(index*1920,0)+offset);await frames(3)
func landing(index: int, x_min: float, x_max: float, floor_y: float, steer: bool=true) -> void:
	var w=app.world;var landed=false;var furthest=w.player.position.x-index*1920
	for i in 150:
		await frames(1)
		var p=w.player;furthest=maxf(furthest,p.position.x-index*1920)
		if w.respawn_delay>0: break
		if p.is_on_floor() and absf(p.position.y-floor_y)<3 and p.position.x>=index*1920+x_min and p.position.x<index*1920+x_max:
			landed=true;break
		if steer and not Input.is_action_pressed("right"): Input.action_press("right")
	print("LAB ROUTE ",index+1," landed=",landed," furthest=",furthest," foot=",w.player.position)
	if not landed: failures+=1;push_error("Lab station landing failed: "+str(index+1))
	release()
func run() -> void:
	app=load("res://main.tscn").instantiate();root.add_child(app);await frames(3);app.start_lab();await frames(3)
	await prepare(0,Vector2(478,624));Input.action_press("ability");await frames(4);Input.action_release("ability");await landing(0,516,624,624)
	await prepare(1,Vector2(474,624));Input.action_press("ability");await frames(25);Input.action_press("right");Input.action_press("jump");Input.action_release("ability");await landing(1,660,1008,624)
	await prepare(2,Vector2(474,624));Input.action_press("ability");await frames(54);Input.action_press("right");Input.action_press("aim_up");Input.action_release("ability");await landing(2,852,1536,624)
	await prepare(3,Vector2(590,624));Input.action_press("ability");await frames(54);Input.action_press("aim_up");Input.action_release("ability");await frames(3);Input.action_press("right");await landing(3,660,1152,288)
	await prepare(4,Vector2(480,330));Input.action_press("ability");await frames(4);Input.action_press("aim_down");Input.action_release("ability");await landing(4,442,518,624,false)
	await prepare(5,Vector2(336,624));Input.action_press("ability");await frames(54);Input.action_press("right");Input.action_press("aim_up");Input.action_release("ability");await frames(14);Input.action_release("right");await landing(5,660,864,432,false)
	await prepare(6,Vector2(408,192));Input.action_press("right");await frames(8);Input.action_press("ability");await frames(24);Input.action_release("ability");await landing(6,756,1536,624)
	release();root.remove_child(app);app.queue_free();await frames(3)
	print("DASH ROUTES TEST COMPLETE: ",failures," failures");call_deferred("quit",1 if failures else 0)
