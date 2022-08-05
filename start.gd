extends Node2D

var request_quit := false

func _init():
	## Get Arguments
	var arguments = {}
	for argument in OS.get_cmdline_args():
		if argument.find("=") > -1:
			var key_value = argument.split("=")
			arguments[key_value[0].lstrip("--")] = key_value[1]
		else: # Options without an argument 
			arguments[argument.lstrip("--")] = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var main = Directory.new()
	var result = {}
	if main.open("res://tests/") == OK:
		main.list_dir_begin()
		var file_name = main.get_next()
		while file_name != "":
			find_test(result, file_name)
			file_name = main.get_next()
	
	for key in result:
		for scene_file in result[key]:
			var scene: TestScene = load(scene_file).instantiate()
			print_rich("[color=orange] Testing [b]", scene.test_name().capitalize(), "[/b] (", scene_file, ") [/color]")
			
			add_child(scene)
			await scene.scene_completed
			remove_child(scene)
	request_quit = true

func _physics_process(_delta: float) -> void:
	if request_quit:
		# Sometimes, it goes out before the printing occurs.
		await get_tree().physics_frame
		await get_tree().physics_frame
		await get_tree().physics_frame
		get_tree().quit()

func find_test(result: Dictionary, folder: String) -> void:
	var dir = Directory.new()
	var path = "res://tests/" + folder  + "/";

	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
	
		while file_name != "":
			var test_dir =  Directory.new()
			if test_dir.open(dir.get_current_dir() + file_name) == OK:
				test_dir.list_dir_begin()
				var test_file_name = test_dir.get_next()
				var test_scene_list = []
				while test_file_name != "":
					var test_path = test_dir.get_current_dir() + "/" + test_file_name
					if test_path.ends_with(".tscn"):
						test_scene_list.append(test_path)
					test_file_name = test_dir.get_next()
				if not test_scene_list.is_empty():
					result[file_name] = test_scene_list
			file_name = dir.get_next()
