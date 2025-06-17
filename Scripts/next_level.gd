# LevelTransition.gd - Script pour votre Area2D
extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# Arrêter et faire clignoter le timer
		var timer_node = get_tree().get_first_node_in_group("speedrun_timer")
		if timer_node and timer_node.has_method("trigger_level_complete"):
			timer_node.trigger_level_complete()
		
		# Changer de niveau
		LevelManager.go_to_next_level()
