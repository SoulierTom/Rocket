# LevelManager.gd - Script Global (AutoLoad)
extends Node

# Liste de tous les niveaux dans l'ordre
var levels = [
	"res://Levels/From_Godot/New Levels/Level_1.tscn",
	"res://Levels/From_Godot/New Levels/Level_2.tscn",
	
	# Ajoutez autant de niveaux que nécessaire
]

# Index du niveau actuel
var current_level_index = 0

# Signal émis quand on change de niveau
signal level_changed(new_level_path)

func _ready():
	# Initialiser l'index du niveau actuel
	_update_current_level_index()

# Met à jour l'index du niveau actuel basé sur la scène courante
func _update_current_level_index():
	var current_scene_path = get_tree().current_scene.scene_file_path
	for i in range(levels.size()):
		if levels[i] == current_scene_path:
			current_level_index = i
			break

# Passe au niveau suivant
func go_to_next_level():
	if current_level_index < levels.size() - 1:
		current_level_index += 1
		var next_level_path = levels[current_level_index]
		_change_to_level(next_level_path)
	else:
		print("Dernier niveau atteint!")
		# Vous pouvez ici gérer la fin du jeu

# Passe au niveau précédent
func go_to_previous_level():
	if current_level_index > 0:
		current_level_index -= 1
		var previous_level_path = levels[current_level_index]
		_change_to_level(previous_level_path)
	else:
		print("Premier niveau atteint!")

# Va à un niveau spécifique par index
func go_to_level(level_index: int):
	if level_index >= 0 and level_index < levels.size():
		current_level_index = level_index
		var level_path = levels[current_level_index]
		_change_to_level(level_path)
	else:
		print("Index de niveau invalide: ", level_index)

# Va à un niveau spécifique par chemin
func go_to_level_by_path(level_path: String):
	var index = levels.find(level_path)
	if index != -1:
		go_to_level(index)
	else:
		print("Niveau non trouvé: ", level_path)

# Change effectivement de niveau avec transition
func _change_to_level(level_path: String):
	if TransitionScreen:
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
	
	get_tree().change_scene_to_file(level_path)
	level_changed.emit(level_path)
	
	# Notifier la caméra après changement (si nécessaire)
	call_deferred("_notify_camera_after_scene_change")

# Fonction pour notifier la caméra (à adapter selon vos besoins)
func _notify_camera_after_scene_change():
	# Ajoutez ici votre logique de notification de caméra
	pass

# Obtient le chemin du niveau actuel
func get_current_level_path() -> String:
	if current_level_index < levels.size():
		return levels[current_level_index]
	return ""

# Obtient l'index du niveau actuel
func get_current_level_index() -> int:
	return current_level_index

# Vérifie s'il y a un niveau suivant
func has_next_level() -> bool:
	return current_level_index < levels.size() - 1

# Vérifie s'il y a un niveau précédent
func has_previous_level() -> bool:
	return current_level_index > 0
