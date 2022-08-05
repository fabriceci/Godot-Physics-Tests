extends CharacterBody2D

var distance: Vector2
var test_only: bool = false
var safe_margin: float = 0.08

func _physics_process(delta: float) -> void:
	move_and_collide(distance, test_only, safe_margin)
