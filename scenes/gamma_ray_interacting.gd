extends Node2D

func _ready():
	var rand_angle = Random.f_range(-0.3, 0.3)
	summon_gamma_ray(null, rand_angle)
	
	
var prev_rot = 0
func summon_gamma_ray(pos, rot):
	var gamma_ray_scene = preload("res://scenes/gamma_ray.tscn")
	var instance = gamma_ray_scene.instance()
	instance.connect("interaction", self, "_on_interaction")
	instance.connect("escaped", self, "_on_escaped")
	add_child(instance)

	if pos != null:
		instance.global_position = pos
		
	if rot != null:
		instance.rotate(prev_rot + rot)
		prev_rot = rot
		

const E_CS137 = 0.663 # MeV
const Z = 11
const R_E_SQ = 0.07941

var gamma_ray_energy = E_CS137
var E_sum = 0
var energy_array = []


func _on_interaction(pos):
	if is_interaction_c(gamma_ray_energy):
		# CSing
		var new_angle = cs_scatter_angle(gamma_ray_energy)
		var new_gamma_ray_energy = cs_scatter_energy(gamma_ray_energy, new_angle)
		E_sum += (gamma_ray_energy - new_gamma_ray_energy)
		gamma_ray_energy = new_gamma_ray_energy
		summon_gamma_ray(pos, new_angle)
	else:
		# PHing
		E_sum += gamma_ray_energy
		Data.energy_array.append(E_sum)


# sometimes emits twice ...
func _on_escaped():
	Data.energy_array.append(gamma_ray_energy)
		

func prob_ph(gamma_energy):
	var a = [1.6268e-9, 1.5274e-9, 1.1330e-9, -9.12e-11]
	var b = [-2.683e-12, -5.110e-13, -2.177e-12, 0]
	var c = [4.173e-2, 1.027e-2, 2.013e-2, 0]
	var p = [1, 2, 3.5, 4]

	var k = gamma_energy / 0.511

	var omega_ph = 0
	for n in range(0, 4):
		var e1 = a[n] + b[n]*Z
		var e2 = 1 + c[n]*Z
		var e3 = pow(k, -p[n])
		omega_ph += (e1 / e2) * e3

	return pow(Z, 5) * omega_ph
	

func prob_c(gamma_energy):
	var k = gamma_energy / 0.511
	var e1 = Z * 2 * PI * R_E_SQ
	var e2 = (1+k) / pow(k, 2)
	var e3 = (2*(1+k)) / (1+2*k)
	var e4 = log(1+2*k) / k
	var e5 = log(1+2*k) / (2*k)
	var e6 = (1+3*k) / pow(1+2*k, 2)
	return e1 * (e2*(e3 - e4) + e5 - e6)
	
	
func is_interaction_c(energy):
	var prob = prob_c(energy) / (prob_c(energy) + prob_ph(energy))
	return Random.uniform() < prob
	
	
func cs_scatter_energy(energy, angle):
	return energy / (1 + (energy / 0.511)*(1 - cos(angle)))
	

func KN_cross_section(energy, theta):
	var a = energy / 0.511
	var eq1 = pow(1 / (1 + a * (1-cos(theta))), 2)
	var eq2 = (1 + pow(cos(theta), 2)) / 2
	var eq3 = 1 + (pow(a, 2) * pow(1 - cos(theta), 2)) / ((1 + pow(cos(theta), 2)) * (1 + a * (1 - cos(theta))))
	return eq1 * eq2 * eq3
	
	
func cs_scatter_angle(energy):
	while true:
		var rand_angle = Random.f_range(0, 2 * PI)
		var q = Random.uniform()
		if q < KN_cross_section(energy, rand_angle):
			return rand_angle
		
	
