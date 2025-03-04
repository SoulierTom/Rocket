extends Area2D

# Chemin de la scène à charger
@export var target_scene: String = "res://Scenes/ending_screen.tscn"

# Nom du groupe pour identifier le joueur
@export var player_group: String = "Player"

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("Player entered death area")
		body.set_process(false)  # Désactive _process du joueur
		body.set_physics_process(false)  # Désactive _physics_process du joueur
		var speedrun_timer = get_tree().root.get_node("Speedrun") # Nom du nœud Timer
		if speedrun_timer:
			speedrun_timer.set_process(false) # Arrête le calcul dans le Timer
			Global.speedrun_time = speedrun_timer.time  # Stocke le temps dans la variable globale
			print("Timer arrêté : ", Global.speedrun_time)

		# Changer de scène
		print("Chargement de la scène :", target_scene)
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file(target_scene)
