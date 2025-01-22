extends Area2D

# Chemin de la scène à charger
@export var target_scene: String = "res://Scenes/ending_screen.tscn"

# Nom du groupe pour identifier le joueur
@export var player_group: String = "Player"

func _on_body_entered(body):
	# Vérifie si l'objet en collision appartient au groupe "Player"
	if body.is_in_group(player_group):
		# Arrêter le Timer de speedrun
		var speedrun_timer = get_tree().root.get_node("res://Scenes/Speedrun") # Chemin du Timer
		if speedrun_timer:
			speedrun_timer.set_process(false) # Arrête le calcul dans le Timer
			print("Timer arrêté : ", speedrun_timer.time)

		# Changer de scène
		print("Chargement de la scène :", target_scene)
		get_tree().change_scene_to_file(target_scene)
