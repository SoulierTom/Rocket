extends Control

var is_using_gamepad = false

func _input(event):
	# Vérifier si l'événement vient d'une manette
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		if not is_using_gamepad:
			is_using_gamepad = true
			_enable_buttons_focus(true)

	# Si une autre entrée (clavier/souris) est détectée, désactiver la manette
	elif event is InputEventMouseMotion or event is InputEventMouseButton or event is InputEventKey:
		if is_using_gamepad:
			is_using_gamepad = false
			_enable_buttons_focus(false)

func _enable_buttons_focus(focus: bool):
	# Parcourir tous les descendants de la hiérarchie pour trouver les boutons
	for button in $MarginContainer/VBoxContainer.get_children():
		if button is Button:
			if focus:
				button.grab_focus()  # Permet de naviguer avec la manette
			else:
				button.release_focus()  # Empêche la navigation avec la manette

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/Level Pico8.tscn")

func _on_quit_pressed():
	get_tree().quit()
