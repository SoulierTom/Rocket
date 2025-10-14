extends Control

@onready var label: Label = $CanvasLayer/Label
@onready var sprite: Sprite2D = $CanvasLayer/Sprite2D

@export var scale_curve: Curve  # Courbe pour l'animation d'échelle
@export var animation_duration: float = 0.3  # Durée de l'animation en secondes
@export var max_scale_multiplier: float = 1.5  # Multiplicateur d'échelle max (1.5 = 150%)

var previous_crystals: int = 0
var animation_time: float = 0.0
var is_animating: bool = false
var base_scale: Vector2

func _ready() -> void:
	# Sauvegarder l'échelle de base du sprite
	base_scale = sprite.scale
	
	# Créer une courbe par défaut si aucune n'est assignée
	if scale_curve == null:
		scale_curve = Curve.new()
		scale_curve.add_point(Vector2(0, 1))  # Début: échelle normale
		scale_curve.add_point(Vector2(0.5, 1.5))  # Milieu: échelle maximale
		scale_curve.add_point(Vector2(1, 1))  # Fin: retour à l'échelle normale
	
	previous_crystals = Global.total_crystal

func _process(delta: float) -> void:
	# Mettre à jour le texte
	label.text = str(Global.total_crystal)
	
	# Détecter si un cristal a été ajouté
	if Global.total_crystal > previous_crystals:
		start_scale_animation()
		previous_crystals = Global.total_crystal
	
	# Gérer l'animation
	if is_animating:
		animation_time += delta
		var progress = animation_time / animation_duration
		
		if progress >= 1.0:
			# Fin de l'animation
			is_animating = false
			sprite.scale = base_scale
		else:
			# Appliquer la courbe
			var curve_value = scale_curve.sample(progress)
			var scale_multiplier = 1.0 + (curve_value - 1.0) * (max_scale_multiplier - 1.0)
			sprite.scale = base_scale * scale_multiplier

func start_scale_animation() -> void:
	is_animating = true
	animation_time = 0.0
