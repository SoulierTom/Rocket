extends Node2D

@onready var crystal_particle: CPUParticles2D = $Crystal_Particle
@onready var timer: Timer = $Timer
@onready var cristal_vrai: Sprite2D = $CristalVrai
@onready var point_light: PointLight2D = $PointLight2D
@onready var area_2d: Area2D = $Area2D

# Courbe pour contrôler l'énergie de la lumière pendant la destruction
@export var energy_curve: Curve

# Variables pour l'animation de la lumière
var initial_energy: float
var is_destructing: bool = false
var destruction_time: float = 0.0

# Variables pour les fragments
@export var fragment_count: int = 5
@export var spawn_radius: float = 20.0
var fragment_scene = preload("res://Scenes/crystal_part.tscn")

func _ready() -> void:
	crystal_particle.emitting = false
	# Stocker l'énergie initiale de la lumière
	initial_energy = point_light.energy
	
	# Créer une courbe par défaut si elle n'est pas assignée
	if energy_curve == null:
		energy_curve = Curve.new()

func _process(delta: float) -> void:
	if is_destructing and timer.time_left > 0:
		# Calculer le progrès de la destruction (0.0 à 1.0)
		var progress = 1.0 - (timer.time_left / timer.wait_time)
		
		# Appliquer la courbe à l'énergie de la lumière
		var energy_multiplier = energy_curve.sample(progress)
		point_light.energy = initial_energy * energy_multiplier

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("boom"):
		destruct()

func destruct():
	$CrystalBreak.play()
	Global.current_level_crystals += 1
	area_2d.queue_free()
	is_destructing = true
	crystal_particle.emitting = true
	cristal_vrai.visible = false
	
	# Créer les fragments ColorRect
	spawn_fragments()
	
	timer.start()

func spawn_fragments():
	# Trouver le joueur
	var player = get_tree().get_first_node_in_group("Player")
	if player == null:
		return
	
	# Obtenir le parent du cristal pour y ajouter les fragments
	var parent = get_parent()
	if parent == null:
		return
	
	for i in range(fragment_count):
		# Instancier la scène crystal_part
		var fragment = fragment_scene.instantiate()
		
		# Calculer une position aléatoire dans le rayon
		var angle = randf() * TAU  # Angle aléatoire (0 à 2π)
		var distance = randf() * spawn_radius  # Distance aléatoire
		var offset = Vector2(cos(angle), sin(angle)) * distance
		
		# Stocker la position globale avant d'ajouter le fragment
		var spawn_position = global_position + offset
		
		# Ajouter le fragment au parent du cristal (pas comme enfant du cristal)
		parent.add_child(fragment)
		
		# Positionner le fragment en coordonnées globales
		fragment.global_position = spawn_position
		
		# Passer la référence du joueur au fragment (si le script du fragment le supporte)
		if fragment.has_method("set_target"):
			fragment.set_target(player)

func _on_timer_timeout() -> void:
	queue_free()
