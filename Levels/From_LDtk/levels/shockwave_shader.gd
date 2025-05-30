extends ColorRect

@export var rayon : Curve
@export var force : Curve
@export var largeur : Curve


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	material.set_shader_parameter("radius", rayon)
	material.set_shader_parameter("strength", rayon)
	material.set_shader_parameter("width", rayon)
