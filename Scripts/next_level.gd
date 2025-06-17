# LevelTransition.gd - Script pour votre Area2D
extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# Simplement appeler le niveau suivant via le gestionnaire global
		LevelManager.go_to_next_level()
