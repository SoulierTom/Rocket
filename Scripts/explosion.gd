extends Area2D

func _ready():
	set_as_top_level(true)
	
func _physics_process(_delta):
	for o in get_overlapping_bodies():
		if o is RigidBody2D:  #Interagis avec les props
			var force = (o.global_position - global_position).normalized()
			force *= 75 
			o.apply_central_impulse(force)
		
		if o is CharacterBody2D:  # Intéragis avec le Player
			var push_direction = (o.global_position - global_position).normalized()
			o.velocity = push_direction * 500  # Ajuste la force pour ton bras

func _on_timer_timeout() -> void:
	queue_free()
