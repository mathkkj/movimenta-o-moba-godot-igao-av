extends Node3D

@onready var sparkles = $sparkles
@onready var explosion = $explosion
@onready var smoke = $smoke


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sparkles.emitting = true
	explosion.emitting = true
	smoke.emitting = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
