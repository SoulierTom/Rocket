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

	# Si l'utilisateur appuie sur "ok", activer le bouton sélectionné
	if Input.is_action_just_pressed("ok"):
		press_focused_button()

func _enable_buttons_focus(focus: bool):
	# Parcourir tous les descendants de la hiérarchie pour trouver les boutons
	for button in $MarginContainer/VBoxContainer/Resume.get_children():
		if button is Button:
			if focus:
				button.grab_focus()  # Permet de naviguer avec la manette
			else:
				button.release_focus()  # Empêche la navigation avec la manette

func press_focused_button():
	# Trouver le bouton actuellement sélectionné et simuler un appui
	for button in $MarginContainer/VBoxContainer/Quit.get_children():
		if button is Button and button.has_focus():
			button.emit_signal("pressed")
			break

func _on_resume_pressed():
	print("Resume button pressed")
	get_tree().paused = false
	queue_free()

func _on_quit_pressed():
	print("Quit button pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Main_Menu.tscn")
