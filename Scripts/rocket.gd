class_name Projectile
extends CharacterBody2D

var direction = Vector2.ZERO
@export var speed = 750
@export var explosion_notifier: Node
@onready var existence: Timer = $Existence
@onready var trail_particles: CPUParticles2D = $trainé
@onready var trail_timer: Timer = $TrailTimer

func _ready():
	set_as_top_level(true)
	look_at(position + direction)
	existence.timeout.connect(queue_free)
	trail_particles.emitting = false
	trail_timer.start()

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(direction * speed * delta)
	
	if collision:
		explosion_notifier = get_parent()
		if explosion_notifier:
			explosion_notifier.call_deferred("create_explosion", global_position)
		queue_free()

func _on_trail_timer_timeout() -> void:
	trail_particles.emitting = true
