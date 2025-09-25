extends Node2D

@onready var crystal_particle: CPUParticles2D = $Crystal_Particle
@onready var timer: Timer = $Timer
@onready var cristal_vrai: Sprite2D = $CristalVrai
@onready var point_light: PointLight2D = $PointLight2D

# Courbe pour contrôler l'énergie de la lumière pendant la destruction
@export var energy_curve: Curve

# Variables pour l'animation de la lumière
var initial_energy: float
var is_destructing: bool = false
var destruction_time: float = 0.0

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
	is_destructing = true
	crystal_particle.emitting = true
	cristal_vrai.visible = false
	timer.start()

func _on_timer_timeout() -> void:
	queue_free()
