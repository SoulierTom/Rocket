extends Control

signal resume_requested  # Ajoutez ce signal

var is_using_gamepad = false

func _ready():
	print("Pause menu ready")

	# Vérifier si les signaux ne sont pas déjà connectés avant de les connecter
	if not $MarginContainer/VBoxContainer/Resume.pressed.is_connected(_on_resume_pressed):
		$MarginContainer/VBoxContainer/Resume.pressed.connect(_on_resume_pressed)

	if not $MarginContainer/VBoxContainer/Quit.pressed.is_connected(_on_quit_pressed):
		$MarginContainer/VBoxContainer/Quit.pressed.connect(_on_quit_pressed)

	# S'assurer que le menu pause fonctionne même quand le jeu est en pause
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Activer le focus sur le premier bouton par défaut
	$MarginContainer/VBoxContainer/Resume.grab_focus()

func _input(event):
	# Détecter l'utilisation de la manette
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		if not is_using_gamepad:
			is_using_gamepad = true
			print("Gamepad detected")
			_enable_buttons_focus(true)

	# Détecter l'utilisation du clavier/souris
	elif event is InputEventMouseMotion or event is InputEventMouseButton or event is InputEventKey:
		if is_using_gamepad:
			is_using_gamepad = false
			print("Keyboard/mouse detected")
			_enable_buttons_focus(false)

	# Gérer la navigation avec la manette
	if is_using_gamepad:
		if Input.is_action_just_pressed("ui_up"):
			_change_focus(-1)
		elif Input.is_action_just_pressed("ui_down"):
			_change_focus(1)

	# Simuler un appui sur le bouton sélectionné avec la manette
	if Input.is_action_just_pressed("ui_accept"):
		press_focused_button()

func _enable_buttons_focus(focus: bool):
	# Activer ou désactiver le focus pour tous les boutons
	for button in $MarginContainer/VBoxContainer.get_children():
		if button is Button:
			if focus:
				button.grab_focus()
			else:
				button.release_focus()

func _change_focus(direction: int):
	var buttons = $MarginContainer/VBoxContainer.get_children()
	var current_focused = null

	# Trouver le bouton actuellement focalisé
	for button in buttons:
		if button is Button and button.has_focus():
			current_focused = button
			break

	if current_focused:
		var index = buttons.find(current_focused)
		var next_index = (index + direction) % buttons.size()
		if next_index < 0:
			next_index = buttons.size() - 1
		buttons[next_index].grab_focus()

func press_focused_button():
	# Simuler un appui sur le bouton sélectionné
	for button in $MarginContainer/VBoxContainer.get_children():
		if button is Button and button.has_focus():
			button.emit_signal("pressed")
			break

func _on_resume_pressed():
	print("Resume button pressed")
	emit_signal("resume_requested")  # Émettre le signal
	queue_free()  # Supprimer le menu pause
	
func _on_quit_pressed():
	print("Quit button pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu_V2.tscn")
