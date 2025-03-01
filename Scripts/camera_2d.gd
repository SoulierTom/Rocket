extends Camera2D

class_name Camera

@export var target: NodePath
@export var offset_y: float = 0.0
@export var zoom_level: Vector2 = Vector2(1, 1)  # Contrôle du zoom par défaut

@onready var player = $Player

func _ready():
	if target == null:
		print("Aucun personnage assigné à la caméra.")
		return

	# Appliquer le zoom initial
	zoom = zoom_level

func _process(_delta):
	if not target:
		return

	# Suivre le personnage avec un décalage optionnel
	global_position = get_node(target).global_position + Vector2(0, offset_y)

	# Si tu veux permettre de modifier dynamiquement le zoom via des inputs :
	handle_zoom_input()

func handle_zoom_input():
	# Augmenter ou réduire le zoom avec des inputs (par exemple : molette ou touches clavier)
	if Input.is_action_just_pressed("zoom_in"):
		zoom *= 0.9  # Réduire le zoom (rapprochement)
	elif Input.is_action_just_pressed("zoom_out"):
		zoom *= 1.1  # Augmenter le zoom (éloignement)
