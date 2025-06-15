extends Area2D

var player_in_area = false
var player_body = null  # Référence au corps du joueur

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("Player entered area")
		player_in_area = true
		player_body = body  # Stocke la référence au joueur
		body.can_jump = false  # Désactive le saut

func _on_body_exited(body):
	if body.is_in_group("Player"):
		print("Player exited area")
		player_in_area = false
		if player_body == body:  # Vérifie que c'est bien le même joueur qui sort
			body.can_jump = true  # Réactive le saut
			player_body = null  # Réinitialise la référence

func _process(delta):
	# Vérifie en permanence si le joueur est dans l'Area2D
	if player_body:
		# Si le joueur est toujours dans l'Area2D, on désactive le saut
		if player_in_area:
			player_body.can_jump = false
		else:
			# Si le joueur n'est plus dans l'Area2D, on réactive le saut
			player_body.can_jump = true
