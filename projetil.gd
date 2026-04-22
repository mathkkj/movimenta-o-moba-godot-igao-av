extends Area3D

@export var velocidade: float = 5.0
@export var altura_arc: float = 3.0
@onready var cena_particula = preload("res://particula_explosao.tscn")

var direcao: Vector3 
var disparado = false

var p0: Vector3
var p1: Vector3
var p2: Vector3
var p3: Vector3

var t = 0.0


func disparar(origem: Vector3, alvo: Vector3) -> void:
	p0 = origem
	p3 = alvo

	p1 = origem + Vector3.UP * altura_arc
	p2 = alvo + Vector3.UP * altura_arc

	global_position = p0
	disparado = true
	
func _physics_process(delta):
	t += delta * velocidade
	var pos_antiga = global_position
	global_position = _cubic_bezier(p0, p1, p2, p3, t)
	
	if global_position == p3:
		var instancia = cena_particula.instantiate()
		get_parent().add_child(instancia)
		instancia.global_position = global_position
		print("explosao")


func _cubic_bezier(p0: Vector3, p1: Vector3, p2: Vector3, p3: Vector3, t: float) -> Vector3:
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var q2 = p2.lerp(p3, t)

	var r0 = q0.lerp(q1, t)
	var r1 = q1.lerp(q2, t)

	var s = r0.lerp(r1, t)
	return s
