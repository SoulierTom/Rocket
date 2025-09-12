extends Area2D
@onready var arm: Node2D = $"."
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var explo = $Explo
@onready var collision_timer: Timer = Timer.new()  # Timer pour gérer la collision
@onready var explo_feu: CPUParticles2D = $Explo_feu

@export var force_player: float = 400.0
@export var animation_duration: float = 0.5
@export var force_objet: int = 75
@export var collision_start_delay: float = 0.0  # Délai avant activation de la collision (équivalent frame 0)
@export var collision_duration: float = 0.1     # Durée d'activation de la collision (équivalent frames 0-1)

var explosion_active: bool = false
var joy_vect = Global.target_pos

func _ready():
	set_as_top_level(true)
	explo.emitting = true
	explo_feu.emitting = true
	# Récupérer automatiquement la durée de vie des particules selon le type
	if explo:
		if explo is CPUParticles2D:
			# Pour CPUParticles2D, la propriété est directement accessible
			animation_duration = explo.lifetime
		elif explo is GPUParticles2D and explo.process_material:
			# Pour GPUParticles2D, passer par le process_material
			var material = explo.process_material as ParticleProcessMaterial
			if material:
				animation_duration = material.emission.get("lifetime", 0.75)
	
	# Désactiver la collision au départ
	if collision_shape:
		collision_shape.disabled = true
	
	# Ajouter et configurer le timer de collision
	add_child(collision_timer)
	collision_timer.one_shot = true
	collision_timer.timeout.connect(_on_collision_timer_timeout)
	
	# Démarrer la séquence d'explosion
	start_explosion_sequence()
	
	# Timer principal pour supprimer l'explosion (basé sur la durée des particules)
	if timer:
		timer.start(animation_duration)

func start_explosion_sequence():
	# Démarrer le timer pour activer la collision après le délai
	if collision_start_delay > 0:
		await get_tree().create_timer(collision_start_delay).timeout
	
	# Activer la collision
	activate_collision()
	
	# Programmer la désactivation de la collision
	collision_timer.start(collision_duration)

func activate_collision():
	if collision_shape and not explosion_active:
		collision_shape.disabled = false
		explosion_active = true
		print("Collision activée")

func deactivate_collision():
	if collision_shape and explosion_active:
		collision_shape.disabled = true
		explosion_active = false
		print("Collision désactivée")

func _on_collision_timer_timeout():
	deactivate_collision()

func _process(_delta):
	# Appliquer l'impulsion seulement quand l'explosion est active
	if explosion_active:
		apply_explosion_impulse()

func apply_explosion_impulse():
	# Applique une impulsion aux objets dans la zone de collision
	for o in get_overlapping_bodies():
		if o is RigidBody2D:
			var force = (o.global_position - global_position).normalized() * force_objet
			o.apply_central_impulse(force)
		
		if o is CharacterBody2D:
			var modif_force = 1.0
			var joystick_vect = -joy_vect.normalized()
			
			if abs(joystick_vect.x) >= 0.5:
				var calc_modif_force1 = clamp(0.5/abs(joystick_vect.x), 0.5, 1)
				modif_force = 0.80 + ((calc_modif_force1 - 0.5) / 0.5) * (1 - 0.85)
				
				var calc_modif_push = clamp(abs(joystick_vect.x)/0.92, 0.76, 1.086)
				if calc_modif_push <= 1:
					joystick_vect.x *= 0.85 - ((calc_modif_push - 0.76) / (1 - 0.76)) * (0.85 - 0.6)
				else:
					joystick_vect.x *= 0.6 + ((calc_modif_push - 1) / (1.086 - 1)) * (0.85 - 0.6)
					
				if joystick_vect.y <= 0.15:
					joystick_vect.y = -sqrt(1-pow(joystick_vect.x, 2))
				else:
					joystick_vect.y *= 0.1
			else:
				var calc_modif_force2 = clamp(0.866/abs(joystick_vect.y), 0.866, 1)
				modif_force = 0.80 + ((calc_modif_force2 - 0.866) / (1 - 0.866)) * (1 - 0.80)
			
			o.velocity = joystick_vect * force_player * modif_force
			Global.player_impulsed = true
			FmodServer.play_one_shot("event:/PlayerMovements/Pushed")

func _on_timer_timeout() -> void:
	queue_free()
