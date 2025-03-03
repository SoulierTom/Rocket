# DeathArea.gd
extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("Player entered death area")
		body.set_process(false)  # Désactive _process du joueur
		body.set_physics_process(false)  # Désactive _physics_process du joueur
		
		if is_instance_valid(DeathScreen):
			print("DeathScreen is valid, playing death animation")
			DeathScreen.death()
			await DeathScreen.on_death_finished
			print("Death animation finished, reloading scene")
			call_deferred("reload_scene")
		else:
			print("Error: DeathScreen is not valid.")

func reload_scene():
	if get_tree():
		print("Reloading current scene")
		get_tree().reload_current_scene()
	else:
		print("Error: Scene tree is null. Cannot reload scene.")
