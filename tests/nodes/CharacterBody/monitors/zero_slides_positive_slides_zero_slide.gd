extends Monitor

enum State {
	START,
	ZERO_SLIDES_BEFORE,
	POSITIVE_SLIDES,
	ZERO_SLIDES_AFTER,
	FAIL
}

var state:= State.START
var target: CharacterBody2D

func is_test_passed() -> bool:
	return state == State.ZERO_SLIDES_AFTER

func monitor_name() -> String:
	return "The number of slide collisions is first zero then positive and then zero again"

func _physics_process(_delta: float) -> void:
	var collision_count: int = target.get_slide_collision_count()
	if state == State.START:
		text = 'start'
		if collision_count == 0:
			state = State.ZERO_SLIDES_BEFORE
			return
		else:
			state = State.FAIL
			return
	if state == State.ZERO_SLIDES_BEFORE:
		text = 'zero slides (before)'
		if collision_count == 0:
			return
		else:
			state = State.POSITIVE_SLIDES
			return
	elif state == State.POSITIVE_SLIDES:
		text = 'positive slides'
		if collision_count == 0:
			state = State.ZERO_SLIDES_AFTER
			return
		else:
			return
	elif state == State.ZERO_SLIDES_AFTER:
		text = 'zero slides (after)'
		if collision_count == 0:
			return
		else:
			state = State.FAIL
			return
	elif state == State.FAIL:
		text = 'fail'
		return
