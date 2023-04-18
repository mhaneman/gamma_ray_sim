extends Node
var rng = RandomNumberGenerator.new()


func _ready():
	randomize()


func uniform():
	return rng.randf_range(0, 1)
	
	
func f_range(a, b):
	return rng.randf_range(a, b)
