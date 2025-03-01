extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"): # Assure-toi que ton personnage est dans le groupe "Player"
		get_tree().reload_current_scene()
