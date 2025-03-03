extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		print("Player entered death area")
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
