class_name Projectile
extends CharacterBody2D

var direction = Vector2.ZERO
@export var speed = 400
@export var explosion_notifier: Node
@onready var existence: Timer = $Existence

func _ready():
	
	set_as_top_level(true)
	look_at(position + direction)
	
	#désactive le projectile au bout d'un certain temps
	existence.timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	
	position += direction * speed * delta
	
	# Déplacement et gestion des collisions
	var collision = move_and_collide(direction * speed * delta)
	
	if collision:
		explosion_notifier = get_parent()
		# Notifie le gestionnaire de créer une explosion
		if explosion_notifier:
			explosion_notifier.call_deferred("create_explosion", global_position)
		
		queue_free()
		
