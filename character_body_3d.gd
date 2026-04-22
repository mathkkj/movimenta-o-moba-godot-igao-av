extends CharacterBody3D

const SPEED = 3
const JUMP_HEIGHT = 5

var clique_duplo = 0

@onready var cena_projetil = preload("res://PROJETIL.tscn")
@onready var cena_marcador = preload("res://marcador.tscn")
@onready var camera = $"../camera"
@onready var obstaculo = $"../obstaculo"

var alvo_movimento: Vector3
var offset_camera
var camera_rot_x = 0.0
var camera_rot_y:= 0.0

var direcao : Vector3


func _ready() -> void:
	offset_camera = camera.global_position - global_position
	camera_rot_x = camera.rotation.x
	camera_rot_y = camera.rotation.y
	alvo_movimento = global_position


func _process(delta: float) -> void:
	

	
	direcao = global_position.direction_to(alvo_movimento)
	look_at(alvo_movimento, Vector3.UP, true)
	
	if clique_duplo >= 2:
		velocity = direcao * (SPEED * 2)
		collision_mask = 2
	else:
		velocity = direcao * SPEED
		collision_mask = 1
	

	if global_position.distance_to(alvo_movimento) < 0.2:
		velocity = Vector3.ZERO
		clique_duplo = 0
		get_tree().call_group("marcadores", "queue_free")

	if Input.is_action_pressed("cameraRot-"):
		camera_rot_y -= 2 * delta
	if Input.is_action_pressed("cameraRot+"):
		camera_rot_y += 2 * delta
	if Input.is_action_pressed("cameraRotX-"):
		camera_rot_x -= 2 * delta
	if Input.is_action_pressed("cameraRotX+"):
		camera_rot_x += 2 * delta

	camera_rot_x = clamp(camera_rot_x, -0.8, 0.35)

	move_and_slide()
	camera.global_position = global_position + offset_camera.rotated(Vector3.RIGHT, camera_rot_x * -1).rotated(Vector3.UP, camera_rot_y * -1)
	camera.look_at(global_position, Vector3.UP)

var arrastando := false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			arrastando = event.pressed
			
			if event.pressed:
				var pos_3d = atirar_raio_da_camera(event.position)
				if pos_3d == null:
					return

				if pos_3d != null:
					alvo_movimento = pos_3d
					clique_duplo += 1
					get_tree().call_group("marcadores", "queue_free")

					var instancia = cena_marcador.instantiate()
					get_parent().add_child(instancia)
					instancia.global_position = pos_3d
				else:
					push_warning("nulo")

		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var pos_3d = atirar_raio_da_camera(event.position)
			if pos_3d != null:
				
				
				var instancia = cena_marcador.instantiate()
				get_parent().add_child(instancia)
				instancia.global_position = pos_3d
				
				
				
				var tiro = cena_projetil.instantiate()
				get_parent().add_child(tiro)
				tiro.global_position = global_position
				tiro.disparar(global_position, pos_3d)
				tiro.look_at(-pos_3d, Vector3.UP)
				
				if tiro.position == pos_3d:
					get_tree().call_group("marcadores", "queue_free")

	if arrastando and event is InputEventMouseMotion:
		clique_duplo = 0
		var pos_3d = atirar_raio_da_camera(event.position)
		if pos_3d != null:
			alvo_movimento = pos_3d
			get_tree().call_group("marcadores", "queue_free")

			var instancia = cena_marcador.instantiate()
			get_parent().add_child(instancia)
			instancia.global_position = pos_3d

			
			
			
			

func atirar_raio_da_camera(mouse_pos: Vector2):
	var camera = get_viewport().get_camera_3d()
	var origin = camera.project_ray_origin(mouse_pos)
	var end = origin + camera.project_ray_normal(mouse_pos) * 1000
	var space_state = get_world_3d().direct_space_state

	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [self, obstaculo]
	var result = space_state.intersect_ray(query)

	if result.is_empty():
		return null

	return result.position
