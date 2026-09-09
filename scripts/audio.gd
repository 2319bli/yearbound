class_name YBAudio
extends Node
var music: AudioStreamPlayer
var voices: Array[AudioStreamPlayer] = []
var effect_volume := 0.75
var music_volume := 0.65
var current := ""
var tones: Dictionary = {}
var charge_hum: AudioStreamPlayer
var water_filter := AudioEffectLowPassFilter.new()
var water_bus := ""
var water_mix := 0.0

func _ready() -> void:
	music = AudioStreamPlayer.new()
	water_bus="YearboundWater"+str(get_instance_id())
	AudioServer.add_bus()
	var bus=AudioServer.bus_count-1
	AudioServer.set_bus_name(bus,water_bus)
	water_filter.cutoff_hz=20500
	AudioServer.add_bus_effect(bus,water_filter)
	music.bus=water_bus
	add_child(music)
	music.finished.connect(func(): music.play())
	charge_hum=AudioStreamPlayer.new();add_child(charge_hum)
	var hum=AudioStreamWAV.new();hum.format=AudioStreamWAV.FORMAT_16_BITS;hum.mix_rate=22050
	var samples=PackedByteArray();samples.resize(22050*2)
	for i in 22050:
		var time=float(i)/22050
		samples.encode_s16(i*2,int((sin(TAU*180*time)*.7+sin(TAU*360*time)*.2+sin(TAU*540*time)*.1)*14000))
	hum.data=samples;hum.loop_mode=AudioStreamWAV.LOOP_FORWARD;hum.loop_begin=0;hum.loop_end=22050;charge_hum.stream=hum
	for i in 8:
		var voice = AudioStreamPlayer.new()
		add_child(voice)
		voices.append(voice)
	for pair in [["jump",520,0.10],["land",140,0.07],["mote",980,0.13],["checkpoint",660,0.3],["death",180,0.3],["select",440,0.065],["complete",880,0.6],["spring",740,0.18]]:
		tones[pair[0]] = tone(pair[1],pair[2])
	tones["charge_full"]=tone(1120,.13)
	tones["dash"]=dash_sound()
	tones["water"]=tone(210,.18)

func water_feedback(submerged: bool, dt: float) -> void:
	water_mix=move_toward(water_mix,1.0 if submerged else 0.0,dt*2)
	water_filter.cutoff_hz=lerpf(20500,1100,water_mix)

func _exit_tree() -> void:
	var index=AudioServer.get_bus_index(water_bus)
	if index>0: AudioServer.remove_bus(index)

func charge_feedback(charging: bool, strength: float) -> void:
	if not charging or effect_volume<=0:
		charge_hum.stop();return
	charge_hum.pitch_scale=lerpf(.8,1.8,strength)
	charge_hum.volume_db=linear_to_db(maxf(.00001,effect_volume*lerpf(.035,.105,strength)))
	if not charge_hum.playing: charge_hum.play()
func dash_sound() -> AudioStreamWAV:
	var stream=AudioStreamWAV.new();stream.format=AudioStreamWAV.FORMAT_16_BITS;stream.mix_rate=22050
	var data=PackedByteArray();data.resize(5000*2)
	var rng=RandomNumberGenerator.new();rng.seed=8302;var smoothed=0.0
	for i in 5000:
		var t=float(i)/5000;smoothed=lerpf(smoothed,rng.randf_range(-1,1),.32)
		data.encode_s16(i*2,int((smoothed*.75+sin(i*.052*(1-t*.6))*.25)*pow(1-t,2)*23000*minf(1,t*24)))
	stream.data=data;return stream

func configure(settings: Dictionary) -> void:
	music_volume = clampf(settings.music,0,1)
	effect_volume = clampf(settings.effects,0,1)
	music.volume_db = linear_to_db(maxf(music_volume * 0.7,0.00001))

func play_track(path: String) -> void:
	if path == current: return
	current = path
	music.stop()
	if ResourceLoader.exists(path):
		music.stream = load(path)
		music.volume_db = -55
		music.play()
		create_tween().tween_property(music,"volume_db",linear_to_db(maxf(music_volume * 0.7,0.00001)),0.65)

func effect(id: String) -> void:
	if id in ["dash","death","complete"]: charge_hum.stop()
	if not tones.has(id): return
	for voice in voices:
		if not voice.playing:
			voice.stream = tones[id]
			voice.volume_db = linear_to_db(effect_volume * 0.25)
			voice.play()
			break

func tone(hz: float, duration: float) -> AudioStreamWAV:
	var result = AudioStreamWAV.new()
	result.format = AudioStreamWAV.FORMAT_16_BITS
	result.mix_rate = 22050
	var bytes = PackedByteArray()
	bytes.resize(int(duration * 22050) * 2)
	for i in bytes.size()/2:
		var t = float(i)/22050
		var envelope = minf(t*100,1) * pow(1-t/duration,2)
		var value = sin(TAU*(hz*t+hz*0.25*t*t/duration)) * envelope * 24000
		bytes.encode_s16(i*2,int(value))
	result.data = bytes
	return result
