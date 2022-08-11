class_name TestScene
extends Node

var runner: TestRunner

func _ready() -> void:
	if get_tree().get_root() == get_parent(): # autostart if the scene is executed alone
		start()

func start() -> void:
	runner = TestRunner.new(self)
	runner.completed.connect(self.completed)
	for child in get_children():
		if child is PhysicsTest2D:
			runner.add_test(child)
	runner.start()
			
func completed() -> void:
	print_rich("[color=orange]--- SCENE TESTS ARE COMPLETED ---[/color]")
