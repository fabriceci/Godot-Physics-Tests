extends Monitor

enum State {
	START,
	NOT_ON_WALL_BEFORE,
	ON_WALL,
	NOT_ON_WALL_AFTER,
	FAIL
}

var state := State.START
var target: CharacterBody2D

func is_test_passed() -> bool:
	return state == State.NOT_ON_WALL_AFTER

func monitor_name() -> String:
	return "The value of is_on_wall() is first false then true and then false again"
	
func _physics_process(_delta: float) -> void:
	var on_wall: bool = target.is_on_wall()
	if state == State.START:
		text = 'start'
		if not on_wall:
			state = State.NOT_ON_WALL_BEFORE
			return
		else:
			state = State.FAIL
			return
	if state == State.NOT_ON_WALL_BEFORE:
		text = 'not on wall (before)'
		if not on_wall:
			return
		else:
			state = State.ON_WALL
			return
	elif state == State.ON_WALL:
		text = 'on wall'
		if not on_wall:
			state = State.NOT_ON_WALL_AFTER
			return
		else:
			return
	elif state == State.NOT_ON_WALL_AFTER:
		text = 'not on wall (after)'
		if not on_wall:
			return
		else:
			state = State.FAIL
			return
	elif state == State.FAIL:
		text = 'fail'
		return
