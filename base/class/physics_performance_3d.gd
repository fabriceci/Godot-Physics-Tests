class_name PhysicsPerformanceTest3D
extends PhysicsTest3D

var NB_FRAME_SMOOTHING = 60
var WARMING_SKIPPED_FRAMES = 60
var _fps_label : Label

var _max_fps := 0.0
var _min_fps := 9999.0
var _average_fps := 0.0
var _average_record := 0
var _smoothed_fps := 20.0

var _frame_cpt := 0
var _fps_buffer := 0.0

var extra_text := []

var _warming := true # wait few frame before start monitoring

func _init() -> void:
	process_mode = PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	if _fps_label:
		_fps_label.text = str(Engine.get_frames_per_second()) + " FPS"

func _physics_process(_delta: float) -> void:

	_frame_cpt += 1
	
	if _warming and _frame_cpt == WARMING_SKIPPED_FRAMES:
		_frame_cpt = 1
		_warming = false
	
	if _warming:
		return
	
	_fps_buffer += Engine.get_frames_per_second()
		
	if _frame_cpt == NB_FRAME_SMOOTHING:
		_smoothed_fps = _fps_buffer / _frame_cpt
		_frame_cpt = 0
		_fps_buffer = 0.0
		_average_record += 1
		_average_fps += _smoothed_fps
		
		if _smoothed_fps > _max_fps:
			_max_fps = _smoothed_fps
		if _smoothed_fps < _min_fps:
			_min_fps = _smoothed_fps

func get_fps():
	return _smoothed_fps

func start() -> void:
	super()
	
	_fps_label = Label.new()
	_fps_label.position = Vector2(20,40)
	_fps_label.set("theme_override_font_sizes/font_size", 18)
	add_child(_fps_label)
	
	process_mode = Node.PROCESS_MODE_INHERIT

func register_result(p_name: String, result: float):
	if not Global.PERFORMANCE_RESULT.has(get_name()):
		Global.PERFORMANCE_RESULT[get_name()] = []
	Global.PERFORMANCE_RESULT[get_name()].append([p_name, _min_fps, _max_fps, _average_fps / _average_record, result])

func test_completed() -> void:
	super()
	if not extra_text.is_empty():
		for s in extra_text:
			output += "[indent][indent][color=green]%s[/color][/indent][/indent]\n" % [s]
	if Global.PERFORMANCE_RESULT.has(get_name()):
		for result in Global.PERFORMANCE_RESULT[get_name()]:
			output += "[indent][indent][color=orange] → %s : [b]%d[/b][/color] | [color=purple](Min FPS: [b]%d[/b] | Max FPS: [b]%d[/b] | Average FPS: [b]%d[/b])[/color][/indent][/indent]\n" % [result[0], result[4], result[1], result[2], result[3]]
	else:
			output += "[indent][indent][color=orange] Simulation completed[/color][/indent][/indent]\n"
	print_rich(output)
	if has_method("clean"):
		call("clean")
	process_mode = PROCESS_MODE_DISABLED
	completed.emit()
	queue_free()

