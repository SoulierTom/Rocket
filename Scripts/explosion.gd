extends Area2D

@onready var arm: Node2D = $"."

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D  # Référence au noeud AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D  # Référence à la zone de collision
@onready var timer: Timer = $Timer  # Timer pour gérer la durée de l'explosion
@onready var animation_player: AnimationPlayer = $AnimationPlayer  # Référence à l'AnimationPlayer
@onready var explo = $Explo

@export var force_player : float = 400.0
@export var animation_duration: float = 0.5  # Durée totale de l'animation en secondes
@export var force_objet: int = 75

var explosion_active: bool = false  # Pour suivre l'état de l'activation de la collision
var joy_vect = Global.target_pos

func _ready():
	set_as_top_level(true)
	explo.emitting = true
	# Assurez-vous que le nœud AnimatedSprite2D existe
	if animated_sprite:
		# Arrêter toute animation en cours et lancer l'animation "Explosion"
		animated_sprite.stop()  # Arrête l'animation en cours, si elle existe
		animated_sprite.play("Explosion")  # Lance l'animation "Explosion"


	
	# Assurez-vous que l'AnimationPlayer existe et joue l'animation
	if animation_player:
		animation_player.play("explosion")  # Lance l'animation "Explosion" dans l'AnimationPlayer

	# Assurez-vous que le CollisionShape2D est désactivé au départ
	if collision_shape:
		collision_shape.disabled = true


	
	# Démarrer le timer avec la durée de l'animation pour supprimer l'explosion
	if timer:
		timer.start(animation_duration)  # La durée est maintenant la durée de l'animation



func _process(_delta):
	# Vérifier si l'animation est en cours et obtenir la frame actuelle

	
	if animated_sprite:
		var current_frame = animated_sprite.frame
		
		# Activer la zone de collision entre certaines frames
		if current_frame >= 0 and current_frame <= 1:
			if not explosion_active:
				# Active la collision et marque l'explosion comme active
				collision_shape.disabled = false
				explosion_active = true
				
		# Désactiver la zone de collision après la frame 5
		if current_frame > 1:
			if explosion_active:
				 #Désactive la collision et marque l'explosion comme inactive
				collision_shape.disabled = true
				explosion_active = false
		
		# Appliquer l'impulsion de l'explosion aux objets dans la zone
		if explosion_active:
			apply_explosion_impulse()

# Applique une impulsion aux objets dans la zone de l'explosion
func apply_explosion_impulse():
	# Applique une impulsion aux objets dans la zone de collision
	for o in get_overlapping_bodies():
		if o is RigidBody2D:
			var force = (o.global_position - global_position).normalized() * force_objet
			  # Applique une force à l'objet
			o.apply_central_impulse(force)
		
		if o is CharacterBody2D:
			var modif_force = 1.0
			var joystick_vect = - joy_vect.normalized()
			print("joystick_vect = " + str(joystick_vect))
			
			if abs(joystick_vect.x) >= 0.5:
				var calc_modif_force1 = clamp(0.5/abs(joystick_vect.x), 0.5, 1)
				modif_force = 0.80 + ((calc_modif_force1 - 0.5) / 0.5 ) * (1 - 0.85)     #la propulsion horizontale est modifié d'un facteur compris entre 1 et 0.80, plus l'horientation est horizontale
				
				var calc_modif_push = clamp(abs(joystick_vect.x)/0.92, 0.76, 1.086)
				if calc_modif_push <= 1:
					joystick_vect.x *= 0.85 - ((calc_modif_push - 0.76) / (1 - 0.76)) * (0.85 - 0.6)
				else:
					joystick_vect.x *= 0.6 + ((calc_modif_push - 1) / (1.086 - 1)) * (0.85 - 0.6)
					
				if joystick_vect.y <= 0.15:
					joystick_vect.y = -sqrt(1-pow(joystick_vect.x,2))
				else:
					joystick_vect.y *= 0.1
					
			else:
				var calc_modif_force2 = clamp(0.866/abs(joystick_vect.y), 0.866, 1)
				modif_force = 0.80 + ((calc_modif_force2 - 0.866) / (1 - 0.866)) * (1 - 0.80)
			
			print("modif force = " + str(modif_force))
			print(" new joystick_vect = " + str(joystick_vect))
			
			o.velocity =  joystick_vect * force_player * modif_force  # Ajuste la force de la poussée
			Global.player_impulsed = true
	
		

# Fonction appelée lorsque le timer se termine (l'explosion est supprimée)
func _on_timer_timeout() -> void:
	# Supprime l'explosion après la durée définie
	queue_free()
