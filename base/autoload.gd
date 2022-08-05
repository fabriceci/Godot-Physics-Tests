extends Node

enum TEST_MODE {
	UNIT,
	STABILITY,
	BENCHMARKT
}

var VERBOSE := true
var MODE := TEST_MODE.UNIT
