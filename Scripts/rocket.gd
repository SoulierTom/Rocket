class_name Projectile
extends CharacterBody2D

var direction = Vector2.ZERO
@export var speed = 750
@export var explosion_notifier: Node
@onready var existence: Timer = $Existence

func _ready():
	set_as_top_level(true)
	look_at(position + direction)
	existence.timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	# Utilisez seulement move_and_collide avec la bonne vitesse
	var collision = move_and_collide(direction * speed * delta)
	
	if collision:
		# Notifie le gestionnaire de créer une explosion
		explosion_notifier = get_parent()
		if explosion_notifier:
			explosion_notifier.call_deferred("create_explosion", global_position)
		queue_free()
