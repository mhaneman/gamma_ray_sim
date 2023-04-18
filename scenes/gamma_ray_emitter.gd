extends Node2D


func start(num_of_rays):
	for __ in range(num_of_rays):
		yield (get_tree().create_timer(0.1), "timeout")
		summon()


func reset():
	for i in $rays.get_children():
		i.queue_free()
	

func summon():
	var gamma_ray_scene = preload("res://scenes/gamma_ray_interacting.tscn")
	var instance = gamma_ray_scene.instance()
	$rays.add_child(instance)
