extends Node2D

var target: Node2D = null
@export var speed: float = 300.0
@export var acceleration_curve: Curve

# Variables pour gérer la progression dans le temps
var time_elapsed: float = 0.0
@export var curve_duration: float = 1.0  # Durée totale de la courbe en secondes

func set_target(player: Node2D):
	target = player

func _ready():
	# Créer une courbe par défaut si elle n'est pas assignée
	if acceleration_curve == null:
		acceleration_curve = Curve.new()
		# Courbe par défaut : accélération progressive
		acceleration_curve.add_point(Vector2(0.0, 0.2))
		acceleration_curve.add_point(Vector2(1.0, 1.0))

func _process(delta: float):
	if target != null:
		# Incrémenter le temps écoulé
		time_elapsed += delta
		
		# Calculer la progression (0.0 à 1.0)
		var progress = min(time_elapsed / curve_duration, 1.0)
		
		# Obtenir le multiplicateur de vitesse depuis la courbe
		var speed_multiplier = acceleration_curve.sample(progress)
		
		# Calculer le mouvement
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * speed_multiplier * delta
		
		# Se détruire quand on atteint le joueur
		if global_position.distance_to(target.global_position) < 10:
			queue_free()
			# FmodServer.play_one_shot("event:/UI-and-Events/CrystalCollect")
