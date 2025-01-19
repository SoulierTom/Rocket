extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D  # Référence au noeud AnimatedSprite2D
@onready var timer: Timer = $Timer  # Timer pour gérer la durée de l'explosion

func _ready():
	set_as_top_level(true)
	
	# Assurez-vous que le nœud AnimatedSprite2D existe
	if animated_sprite:
		# Arrêter toute animation en cours et lancer l'animation "Explosion"
		animated_sprite.stop()  # Arrête l'animation en cours, si elle existe
		animated_sprite.play("Explosion")  # Lance l'animation "Explosion" (vérifiez qu'elle existe dans le AnimatedSprite2D)
	else:
		print("Erreur : AnimatedSprite2D n'a pas été trouvé !")
	
	# Démarrer le timer avec une durée manuelle (par exemple, 1 seconde pour l'explosion)
	if timer:
		timer.start(0.15)  # Durée de l'explosion en secondes
	else:
		print("Erreur : Timer n'a pas été trouvé !")

func _physics_process(_delta):
	# Vérifier les objets dans la zone de l'explosion
	for o in get_overlapping_bodies():
		if o is RigidBody2D:  # Interagit avec les objets RigidBody2D
			var force = (o.global_position - global_position).normalized()
			force *= 75 
			o.apply_central_impulse(force)
		
		if o is CharacterBody2D:  # Interagit avec le joueur (CharacterBody2D)
			var push_direction = (o.global_position - global_position).normalized()
			o.velocity = push_direction * 500  # Ajuste la force de la poussée

# Fonction appelée lorsque le timer se termine
func _on_timer_timeout() -> void:
	# Supprime l'explosion après la durée définie
	queue_free()
