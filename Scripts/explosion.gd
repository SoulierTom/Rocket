extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D  # Référence au noeud AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D  # Référence à la zone de collision
@onready var timer: Timer = $Timer  # Timer pour gérer la durée de l'explosion
@onready var animation_player: AnimationPlayer = $AnimationPlayer  # Référence à l'AnimationPlayer

@export var force_player : float = 400.0
@export var animation_duration: float = 0.5  # Durée totale de l'animation en secondes
@export var force_objet: int = 75

var explosion_active: bool = false  # Pour suivre l'état de l'activation de la collision

func _ready():
	set_as_top_level(true)
	
	# Assurez-vous que le nœud AnimatedSprite2D existe
	if animated_sprite:
		# Arrêter toute animation en cours et lancer l'animation "Explosion"
		animated_sprite.stop()  # Arrête l'animation en cours, si elle existe
		animated_sprite.play("Explosion")  # Lance l'animation "Explosion"
	else:
		print("Erreur : AnimatedSprite2D n'a pas été trouvé !")
	
	# Assurez-vous que l'AnimationPlayer existe et joue l'animation
	if animation_player:
		animation_player.play("explosion")  # Lance l'animation "Explosion" dans l'AnimationPlayer
	else:
		print("Erreur : AnimationPlayer n'a pas été trouvé !")
	
	# Assurez-vous que le CollisionShape2D est désactivé au départ
	if collision_shape:
		collision_shape.disabled = true
	else:
		print("Erreur : CollisionShape2D n'a pas été trouvé !")
	
	# Démarrer le timer avec la durée de l'animation pour supprimer l'explosion
	if timer:
		timer.start(animation_duration)  # La durée est maintenant la durée de l'animation
	else:
		print("Erreur : Timer n'a pas été trouvé !")

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
			var push_direction = (o.global_position - global_position).normalized()
			var push_pow_x = pow(push_direction.x,2) * sign(push_direction.x)
			var push_pow_y = pow(push_direction.y,2) * sign(push_direction.y)

			print("push.x = " + str(push_pow_x))
			print("push.y = " + str(push_pow_y))
			
			push_pow_x *= 0.75
			if push_direction.y <=0:
				if push_direction.x <=0:
					push_pow_y = -(push_pow_x + 1)
				else:
					push_pow_y = -(1 - push_pow_x)
			else:
				push_pow_y *= 0.0
			print("new.push.x = " + str(push_pow_x))
			print("new.push.y = " + str(push_pow_y))
			var new_push_dir = Vector2(push_pow_x,push_pow_y)
			print("new dir = " + str(new_push_dir))
			o.velocity = new_push_dir * force_player  # Ajuste la force de la poussée
			Global.player_impulsed = true
	
		

# Fonction appelée lorsque le timer se termine (l'explosion est supprimée)
func _on_timer_timeout() -> void:
	# Supprime l'explosion après la durée définie
	queue_free()
