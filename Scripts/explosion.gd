extends Area2D

@onready var arm: Node2D = $"."
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var explo = $Explo
@onready var rigid_body: RigidBody2D = $RigidBody2D
@onready var rigid_shape: CollisionShape2D = $RigidBody2D/CollisionShape2D
@onready var centre: Marker2D = $centre

@export var force_player: float = 400.0
@export var animation_duration: float = 0.5
@export var force_objet: int = 75
@export var start_radius: float = 1
@export var end_radius: float = 37
@export var radius_curve: Curve

var joy_vect = Global.target_pos
var elapsed_time: float = 0.0
var already_impulsed := {}

func _ready():
	set_as_top_level(true)
	explo.emitting = true

	if animated_sprite:
		animated_sprite.stop()
		animated_sprite.play("Explosion")

	if animation_player:
		animation_player.play("explosion")

	if rigid_shape and rigid_shape.shape is CircleShape2D:
		rigid_shape.shape.radius = start_radius

	if timer:
		timer.start(animation_duration)

	# Gèle le rigidbody pour l’empêcher de bouger
	rigid_body.freeze = true
	rigid_body.gravity_scale = 0
	rigid_body.linear_velocity = Vector2.ZERO
	rigid_body.angular_velocity = 0
	rigid_body.set_deferred("can_sleep", true)
	rigid_body.set_deferred("sleeping", true)

func _process(delta):
	elapsed_time += delta

	# Garde le rigidbody à la position du marker
	rigid_body.global_position = centre.global_position

	# Grandissement du CollisionShape du RigidBody2D selon la courbe
	if rigid_shape and rigid_shape.shape is CircleShape2D and radius_curve:
		var t = clamp(elapsed_time / animation_duration, 0.0, 1.0)
		var curve_value = radius_curve.sample(t)
		rigid_shape.shape.radius = lerp(start_radius, end_radius, curve_value)

	apply_explosion_impulse()

func apply_explosion_impulse():
	for o in rigid_body.get_colliding_bodies():
		if already_impulsed.has(o.get_instance_id()):
			continue

		already_impulsed[o.get_instance_id()] = true

		if o is RigidBody2D:
			var force = (o.global_position - global_position).normalized() * force_objet
			o.apply_central_impulse(force)

		elif o is CharacterBody2D:
			var modif_force = 1.0
			var joystick_vect = -joy_vect.normalized()

			if abs(joystick_vect.x) >= 0.5:
				var calc_modif_force1 = clamp(0.5 / abs(joystick_vect.x), 0.5, 1)
				modif_force = 0.80 + ((calc_modif_force1 - 0.5) / 0.5) * (1 - 0.85)

				var calc_modif_push = clamp(abs(joystick_vect.x) / 0.92, 0.76, 1.086)
				if calc_modif_push <= 1:
					joystick_vect.x *= 0.85 - ((calc_modif_push - 0.76) / (1 - 0.76)) * (0.85 - 0.6)
				else:
					joystick_vect.x *= 0.6 + ((calc_modif_push - 1) / (1.086 - 1)) * (0.85 - 0.6)

				if joystick_vect.y <= 0.15:
					joystick_vect.y = -sqrt(1 - pow(joystick_vect.x, 2))
				else:
					joystick_vect.y *= 0.1
			else:
				var calc_modif_force2 = clamp(0.866 / abs(joystick_vect.y), 0.866, 1)
				modif_force = 0.80 + ((calc_modif_force2 - 0.866) / (1 - 0.866)) * (1 - 0.80)

			o.velocity = joystick_vect * force_player * modif_force
			Global.player_impulsed = true

func _on_timer_timeout() -> void:
	queue_free()
