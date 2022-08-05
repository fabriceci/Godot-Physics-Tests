class_name SceneTest
extends Node

signal scene_completed

func _ready() -> void:
	handle_child(self)

func handle_child(parent: Node) -> void:
	for node in parent.get_children():
		if node is PhysicsTest2D:
			launch_test(node)
			await node.completed
			remove_child(node)
		# TO DO: handle child in //
		#elif node.get_child_count() > 0:
		#	handle_child(node)
	scene_completed.emit()
			
func launch_test(node: PhysicsTest2D) -> void:
	node.start()
	
func test_name() -> String:
	assert(false, "ERROR: You must implement test_name()");
	return ""

func test_description() -> String:
	return ""
