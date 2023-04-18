extends Node2D

signal interaction(pos)
signal escaped

onready var raycast = $head
onready var line = $Line2D

var head = Vector2(0, 0)
var speed = 50

var penetration_depth = 0
var current_depth = 0

func _ready():
	penetration_depth = 100 * calc_depth()
	

func calc_depth():
	var lambda = 2.24 * 3.67
	return (-1/lambda) * log(1 - Random.uniform())
	

func _physics_process(delta):
	update_head(delta)
	
	if current_depth >= penetration_depth:
		self.emit_signal("interaction", raycast.global_position)
		set_physics_process(false)
		
	if abs(raycast.global_position.x) > 800 or abs(raycast.global_position.y) > 800:
		line.default_color = Color(0.0, 0.0, 1.0)
		self.emit_signal("escaped")
		set_physics_process(false)
		
		
	if raycast.is_colliding():
		var coll_name = raycast.get_collider().name
		
		if coll_name == "lead":
			line.default_color = Color(1.0, 0.0, 0.0)
			current_depth += speed * delta
			
		if coll_name == "walls":
			line.default_color = Color(0.0, 0.0, 1.0)
			self.emit_signal("escaped")
			set_physics_process(false)
		

func update_head(delta):
	head.x += speed * delta
	raycast.position = head
	line.points[1] = head
	

