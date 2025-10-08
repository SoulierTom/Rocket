extends Node2D

var target: Node2D = null
@export var speed: float = 300.0
@export var acceleration_curve: Curve

# Courbes pour la lumière
@export_group("Light Animation")
@export var spawn_light_curve: Curve
@export var despawn_light_curve: Curve
@export var spawn_duration: float = 0.5  # Durée de l'apparition
@export var despawn_duration: float = 0.3  # Durée de la disparition
@export var max_light_energy: float = 1.0  # Énergie maximale de la lumière

# Variables pour gérer la progression dans le temps
var time_elapsed: float = 0.0
@export var curve_duration: float = 1.0  # Durée totale de la courbe en secondes

# États de l'animation
enum State { SPAWNING, MOVING, DESPAWNING }
var current_state: State = State.SPAWNING
var state_time: float = 0.0

@onready var point_light: PointLight2D = $PointLight2D
@onready var color_rect: ColorRect = $ColorRect

func set_target(player: Node2D):
	target = player

func _ready():
	# Initialiser la lumière à 0
	if point_light:
		point_light.energy = 0.0

func _process(delta: float):
	state_time += delta
	
	match current_state:
		State.SPAWNING:
			_process_spawning(delta)
		State.MOVING:
			_process_moving(delta)
		State.DESPAWNING:
			_process_despawning(delta)

func _process_spawning(delta: float):
	# Animation d'apparition de la lumière
	var progress = min(state_time / spawn_duration, 1.0)
	var light_multiplier = spawn_light_curve.sample(progress)
	
	if point_light:
		point_light.energy = max_light_energy * light_multiplier
	
	# Passer à l'état suivant
	if progress >= 1.0:
		current_state = State.MOVING
		state_time = 0.0

func _process_moving(delta: float):
	if target != null:
		# Maintenir la lumière à son maximum
		if point_light:
			point_light.energy = max_light_energy
		
		# Incrémenter le temps écoulé
		time_elapsed += delta
		
		# Calculer la progression (0.0 à 1.0)
		var progress = min(time_elapsed / curve_duration, 1.0)
		
		# Obtenir le multiplicateur de vitesse depuis la courbe
		var speed_multiplier = acceleration_curve.sample(progress)
		
		# Calculer le mouvement
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * speed_multiplier * delta
		
		# Commencer la disparition quand on atteint le joueur
		if global_position.distance_to(target.global_position) < 10:
			current_state = State.DESPAWNING
			color_rect.visible = false
			state_time = 0.0

func _process_despawning(_delta: float):
	# Animation de disparition de la lumière
	var progress = min(state_time / despawn_duration, 1.0)
	var light_multiplier = despawn_light_curve.sample(progress)
	
	if point_light:
		point_light.energy = max_light_energy * light_multiplier
	
	# Se détruire à la fin de l'animation
	if progress >= 1.0:
		queue_free()
		FmodServer.play_one_shot("event:/UI-and-Events/CrystalCollect")
