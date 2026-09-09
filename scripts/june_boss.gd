class_name YBJuneBoss
extends RefCounted
## Five connected platforming arenas. Phase checkpoints never reset completed phases.
var host: Node2D
var phase=0
var phase_time=0.0
var attack_clock=1.5
var attack=0
var chase_time=0.0
var cleared=false
var defeated=false
var aftermath=0.0
func _init(world: Node2D) -> void:host=world
func data() -> Dictionary:return host.spec.boss.phases[phase]
func earned_time() -> float:
	var value=phase_time
	for i in phase:value+=float(host.spec.boss.phases[i].duration)
	return value
func enter(index: int) -> void:
	phase=clampi(index,0,host.spec.boss.phases.size()-1);phase_time=0;attack_clock=1.5;attack=0;chase_time=0;cleared=false;defeated=false;aftermath=0
	var at=data().checkpoint;host.checkpoint=Vector2(at[0],at[1]);host.boss_active=true;host.projectiles.clear();host.boss_time=earned_time()
func retry() -> void:
	var done=cleared;var calm=defeated
	enter(phase)
	if done:phase_time=float(data().duration);cleared=true;defeated=calm;host.boss_time=earned_time()
func update(dt: float) -> void:
	if host.respawn_delay>0:return
	var p=host.player;var arena=data();var end=float(arena.to_x)
	p.position.x=maxf(p.position.x,float(arena.from_x)+24)
	if defeated:
		aftermath+=dt
		if p.position.distance_to(Vector2(host.spec.goal[0],host.spec.goal[1]))<58:host.win()
		return
	if arena.pattern=="chase" and not cleared:
		chase_time+=dt
		phase_time=clampf((p.position.x-float(arena.from_x)-120)/(end-float(arena.from_x)-280),0,1)*float(arena.duration)
		if p.position.x<chase_wall()+16:host.die();return
	else:phase_time=minf(float(arena.duration),phase_time+dt)
	var was_clear=cleared
	cleared=phase_time>=float(arena.duration)-.001
	host.boss_time=earned_time()
	if cleared and not was_clear:host.checkpoint_reached.emit()
	if cleared:
		host.projectiles.clear()
		if phase==host.spec.boss.phases.size()-1:
			defeated=true;host.sound.emit("complete");return
		if p.position.x>=end+24:
			enter(phase+1);host.checkpoint_reached.emit();host.sound.emit("checkpoint")
	else:p.position.x=minf(p.position.x,end-60)
	if cleared:return
	attack_clock-=dt
	if attack_clock<=0:
		attack+=1;attack_clock=float(arena.interval)*(1.25 if host.assist else 1)
		var warning=float(arena.warning)*(1.3 if host.assist else 1)
		var target=clampf(p.position.x+p.velocity.x*.22,float(arena.from_x)+70,end-70)
		spawn(Vector2(target,-50),Vector2(0,340+phase*32),warning,17,"rain")
		if arena.pattern in ["terraces","crosswind","final"]:
			var side=1 if attack%2 else -1
			var start=clampf(host.camera_x+(0 if side==1 else 1280),float(arena.from_x),end)
			spawn(Vector2(start,574 if attack%3 else 390),Vector2(side*(285+phase*25),0),warning+.15,17,"sweep")
		if arena.pattern in ["crosswind","final"] and attack%2==0:
			spawn(Vector2(clampf(target+200,float(arena.from_x)+80,end-80),-60),Vector2(-55,400),warning+.25,16,"rain")
	for i in range(host.projectiles.size()-1,-1,-1):
		var shot=host.projectiles[i];shot.delay-=dt
		if shot.delay>0:continue
		var before: Vector2=shot.pos;shot.pos+=shot.vel*dt
		if Geometry2D.get_closest_point_to_segment(p.position-Vector2(0,21),before,shot.pos).distance_to(p.position-Vector2(0,21))<float(shot.r)+13:host.die();return
		if shot.pos.y>780 or shot.pos.x<float(arena.from_x)-100 or shot.pos.x>end+100:host.projectiles.remove_at(i)
func spawn(at: Vector2, velocity: Vector2, delay: float, radius: float, kind: String) -> void:
	host.projectiles.append({"pos":at,"vel":velocity,"delay":delay,"r":radius,"kind":kind})
func chase_wall() -> float:return float(data().from_x)-380+chase_time*(175 if host.assist else 215)
func draw(n: Node2D) -> void:
	var arena=data();var end=float(arena.to_x);var center=clampf(host.camera_x+800,float(arena.from_x)+350,end-250)
	var at=Vector2(center,110+sin(host.age)*16-(phase_time-float(arena.duration))*80 if defeated else 110+sin(host.age)*16)
	var bird=YBLandscape.texture("res://art/squallkeeper.png")
	if bird and not defeated:n.draw_texture_rect(bird,Rect2(at-Vector2(150,65),Vector2(300,150)),false)
	if not defeated:
		var tint=Color("e6d79e") if cleared else Color("92a5ad")
		n.draw_line(Vector2(end-44,-48),Vector2(end-44,624),Color(tint,.5),5)
		if cleared:
			for j in 3:n.draw_polyline(PackedVector2Array([Vector2(end-130+j*30,500),Vector2(end-118+j*30,511),Vector2(end-130+j*30,522)]),Color("ffe5a0"),3)
	if arena.pattern=="chase" and not cleared:
		var wall=chase_wall();n.draw_rect(Rect2(wall-120,-50,120,720),Color(.25,.35,.43,.68))
		for j in 22:n.draw_line(Vector2(wall-90+(j%3)*19,j*31),Vector2(wall+10,j*31-15),Color("b7c3b5"),3)
	for shot in host.projectiles:
		var pos: Vector2=shot.pos
		if shot.delay>0:
			if shot.kind=="rain":n.draw_line(Vector2(pos.x,160),Vector2(pos.x,612),Color(1,.75,.34,.5),2);n.draw_circle(Vector2(pos.x,607),8,Color("f0c17b"))
			else:n.draw_line(Vector2(host.camera_x,pos.y),Vector2(host.camera_x+1280,pos.y),Color(1,.75,.34,.45),2)
		else:
			n.draw_circle(pos,shot.r+5,Color(1,.7,.3,.16));n.draw_circle(pos,shot.r,Color("e3a465"));n.draw_circle(pos,shot.r-6,Color("fff1c1"))
	if defeated:
		n.draw_circle(Vector2(host.camera_x+960,130),70,Color(1,.88,.54,.25));YBLandscape.gate(n,Vector2(host.spec.goal[0],host.spec.goal[1]),host.age)
