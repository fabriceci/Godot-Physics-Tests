class_name PhysicsPerformanceTest2D
extends PhysicsTest2D

var fps_label : Label

var max_fps := 0.0
var min_fps := 9999.0
var average_fps := 0.0
var fps_frame := 0.0

var warming := true # wait few frame before start monitoring
var nb_warming_frame = 60 

func _init() -> void:
	process_mode = PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	if fps_label:
		fps_label.text = str(Engine.get_frames_per_second()) + " FPS"

func _physics_process(_delta: float) -> void:
	var fps = Engine.get_frames_per_second()
	fps_frame += 1
	
	if warming and fps_frame < nb_warming_frame:
		return
	if warming:
		warming = false
		fps_frame = 0

	average_fps += fps
	
	if fps > max_fps:
		max_fps = fps
	if fps < min_fps:
		min_fps = fps

func get_fps():
	if warming:
		return 60
	return Engine.get_frames_per_second()

func start() -> void:
	super()
	
	fps_label = Label.new()
	fps_label.position = TOP_LEFT + Vector2(20,20)
	fps_label.set("theme_override_font_sizes/font_size", 18)
	add_child(fps_label)
	
	process_mode = Node.PROCESS_MODE_INHERIT

func register_result(p_name: String, result: float):
	if not Global.PERFORMANCE_RESULT.has(get_name()):
		Global.PERFORMANCE_RESULT[get_name()] = []
	Global.PERFORMANCE_RESULT[get_name()].append([p_name, min_fps, max_fps, average_fps / fps_frame, result])

func test_completed() -> void:
	super()
	for result in Global.PERFORMANCE_RESULT[get_name()]:
		output += "[indent][indent][color=orange] → %s : [b]%d[/b][/color] | [color=purple](Min FPS: [b]%d[/b] | Max FPS: [b]%d[/b] | Average FPS: [b]%d[/b])[/color][/indent][/indent]\n" % [result[0], result[4], result[1], result[2], result[3]]
	print_rich(output)
	process_mode = PROCESS_MODE_DISABLED
	if has_method("clean"):
		call("clean")
	await get_tree().create_timer(.5).timeout # wait for fps 
	queue_free()
	completed.emit()
