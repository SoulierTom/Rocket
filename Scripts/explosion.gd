extends Area2D

func _ready():
	set_as_top_level(true)
	
func _physics_process(delta):
	for o in get_overlapping_bodies():
		if o is RigidBody2D:
			var force = (o.global_position - global_position).normalized()
			force *= 75 # Applique une force de 400 unités
			o.apply_central_impulse(force)
		
		if o is CharacterBody2D:  # Vérifie si c'est un "Arm"
			var push_direction = (o.global_position - global_position).normalized()
			o.velocity = push_direction * 500  # Ajuste la force pour ton bras
		
		
 # Si c'est un CharacterBody2D, modifie sa vélocité
		

func _on_timer_timeout() -> void:
	queue_free()
