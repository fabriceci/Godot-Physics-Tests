extends Node

enum TEST_MODE {
	REGRESSION,
	QUALITY,
	PERFORMANCE
}

# View
var WINDOW_SIZE := Vector2(1024,600)
var NUMBER_TEST_PER_ROW := 4
var MAXIMUM_PARALLEL_TESTS := 40

# Output
var VERBOSE := false
var HAS_ERROR := false
