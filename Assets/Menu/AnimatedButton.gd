extends TextureButton
class_name CustomButton

# Courbes éditables dans l'inspecteur
@export var focus_scale_curve: Curve
@export var press_scale_curve: Curve

# Paramètres d'animation
@export var focus_duration: float = 0.3
@export var press_duration: float = 0.2
@export var focus_max_scale: float = 1.2
@export var press_max_scale: float = 1.4

# Variables internes
var original_scale: Vector2
var current_tween: Tween
var is_focused: bool = false

func _ready():
	# Sauvegarder la taille originale
	original_scale = scale
	
	# Configurer le bouton pour recevoir le focus
	focus_mode = Control.FOCUS_ALL
	
	# Connecter les signaux
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	button_down.connect(_on_button_down)

func _on_focus_entered():
	is_focused = true
	animate_with_curve(focus_scale_curve, focus_max_scale, focus_duration)

func _on_focus_exited():
	is_focused = false
	animate_to_original_size()

func _on_button_down():
	if is_focused:
		animate_with_curve(press_scale_curve, press_max_scale, press_duration)

func animate_with_curve(curve: Curve, max_scale: float, duration: float):
	# Arrêter l'animation précédente
	if current_tween:
		current_tween.kill()
	
	# Si pas de courbe, utiliser une animation simple
	if curve == null:
		current_tween = create_tween()
		var target_scale = original_scale * max_scale
		current_tween.tween_property(self, "scale", target_scale, duration)
		return
	
	# Animation avec courbe personnalisée
	current_tween = create_tween()
	
	# Créer une fonction qui sera appelée à chaque frame
	current_tween.tween_method(
		func(progress: float):
			var curve_value = curve.sample(progress)
			var scale_multiplier = 1.0 + (max_scale - 1.0) * curve_value
			scale = original_scale * scale_multiplier,
		0.0,
		1.0,
		duration
	)

func animate_to_original_size():
	if current_tween:
		current_tween.kill()
	
	current_tween = create_tween()
	current_tween.tween_property(self, "scale", original_scale, 0.2)
