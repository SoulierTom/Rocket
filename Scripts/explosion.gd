extends Area2D


func _ready():
	set_as_top_level(true)


# Called when the node enters the scene tree for the first time.
func _physics_process(delta):
	for o in get_overlapping_bodies():
		if o is RigidBody2D:
			var force = (o.global_position - global_position).normalized()
			force *= 10  # Applique une force de 400 unités
			o.apply_central_impulse(force)

 # Si c'est un CharacterBody2D, modifie sa vélocité
		elif o is CharacterBody2D:
			var push_direction = (o.global_position - global_position).normalized()
			o.velocity += push_direction * 30  # Ajuste la force selon tes besoins
			print("Impulse appliquée à un CharacterBody2D")

func _on_timer_timeout() -> void:
	queue_free()
