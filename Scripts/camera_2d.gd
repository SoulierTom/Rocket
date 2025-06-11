extends Camera2D

class_name Camera

@export var target: NodePath
@export var offset_y: float = 0.0
@export var zoom_level: Vector2 = Vector2(1, 1)  # Contrôle du zoom par défaut

@onready var player = get_node("/root/Level 2/Player")  # Chemin absolu

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
