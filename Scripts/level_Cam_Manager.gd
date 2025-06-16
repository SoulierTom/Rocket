extends Node

class_name LevelCameraController

# Paramètres exportés pour configurer depuis l'éditeur
@export var camera_vertical_offset: float = 0.0  # Offset Y pour ce niveau
@export var apply_offset_on_ready: bool = true     # Appliquer l'offset dès le start
@export var use_smooth_transition: bool = false    # Transition fluide ou instantanée (défaut: instantané au spawn)
@export var force_instant_at_spawn: bool = true    # Force l'application instantanée au spawn même si smooth_transition est true

# Référence à la caméra
var camera: Camera

func _ready():
	# Trouver la caméra dans la scène
	camera = get_tree().get_first_node_in_group("camera")
	if not camera:
		# Si pas de groupe, chercher par type
		camera = get_viewport().get_camera_2d()
	
	if not camera:
		print("Erreur: Aucune caméra trouvée dans le niveau")
		return
	
	# Appliquer l'offset si configuré
	if apply_offset_on_ready:
		# Au spawn, toujours appliquer instantanément si force_instant_at_spawn est activé
		if force_instant_at_spawn:
			camera.set_dynamic_offset_y_instant(camera_vertical_offset)
		else:
			set_camera_offset(camera_vertical_offset)

# Fonction pour définir l'offset de la caméra
func set_camera_offset(offset: float):
	if not camera:
		return
	
	if use_smooth_transition:
		camera.set_dynamic_offset_y(offset)
	else:
		camera.set_dynamic_offset_y_instant(offset)

# Fonction pour réinitialiser l'offset
func reset_camera_offset():
	if camera:
		camera.reset_dynamic_offset_y()

# Fonction pour ajouter un offset temporaire
func add_temporary_offset(temp_offset: float):
	if camera:
		camera.add_temp_offset_y(temp_offset)

# Fonction appelée quand le niveau se termine/change
func _exit_tree():
	# Optionnel: réinitialiser l'offset quand on quitte le niveau
	if camera:
		camera.reset_dynamic_offset_y()
