class_name PhysicsPerformanceTest2D
extends PhysicsTest2D

var fps_label : Label

var max_fps := 0.0
var min_fps := 9999.0
var average_fps := 0.0
var fps_frame := 0.0

var warming = true # When you run the scene for the first time, it will start at 1 fps for few frames.

func _init() -> void:
	process_mode = PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	if fps_label:
		fps_label.text = str(Engine.get_frames_per_second()) + " FPS"

func _physics_process(_delta: float) -> void:
	var fps = Engine.get_frames_per_second()

	if warming and fps != 1:
		warming = false
	if warming:
		return

	average_fps += fps
	fps_frame += 1
	
	if fps > max_fps:
		max_fps = fps
	if fps < min_fps:
		min_fps = fps

func start() -> void:
	super()
	
	fps_label = Label.new()
	fps_label.position = TOP_LEFT + Vector2(20,20)
	fps_label.set("theme_override_font_sizes/font_size", 18)
	add_child(fps_label)
	
	process_mode = Node.PROCESS_MODE_INHERIT

func test_completed(p_messages:= []) -> void:
	for message in p_messages:
		print_rich("[indent][indent] → %s [/indent][/indent]" % [message])
	print_rich("[indent][indent] → Min FPS: %d | Max FPS: %d | Average FPS: %d[/indent][/indent]" % [min_fps, max_fps, round(average_fps/fps_frame)])
	process_mode = PROCESS_MODE_DISABLED
	completed.emit()
	queue_free()
