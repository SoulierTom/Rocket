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
	for button in $MarginContainer/VBoxContainer.get_children():
		if button is Button:
			if focus:
				button.grab_focus()  # Permet de naviguer avec la manette
			else:
				button.release_focus()  # Empêche la navigation avec la manette

func press_focused_button():
	# Trouver le bouton actuellement sélectionné et simuler un appui
	for button in $MarginContainer/VBoxContainer.get_children():
		if button is Button and button.has_focus():
			button.emit_signal("pressed")
			break

func _on_play_pressed():
	Global.speedrun_time = 0.0
	Global.timer_initialized = false
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished

	print("Arbre de scène:", get_tree())
	if get_tree():
		get_tree().change_scene_to_file("res://Levels/From_LDtk/levels/Level_0.scn")
	else:
		print("Erreur: get_tree() est null")

func _on_quit_pressed():
	get_tree().quit()
