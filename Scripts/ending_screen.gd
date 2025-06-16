extends Control

@onready var ending_screen: Control = $"."

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
	for button in $CanvasLayer.get_children():
		if button is Button:
			if focus:
				button.grab_focus()  # Permet de naviguer avec la manette
			else:
				button.release_focus()  # Empêche la navigation avec la manette

func press_focused_button():
	# Trouver le bouton actuellement sélectionné et simuler un appui
	for button in $CanvasLayer.get_children():
		if button is Button and button.has_focus():
			button.emit_signal("pressed")
			break

func _ready():
	# Récupérer le Label
	var label = $CanvasLayer/temps_final
	if label:
		# Convertir le temps en minutes, secondes et centièmes
		var total_seconds = Global.speedrun_time
		var minutes = int(total_seconds) / 60
		var seconds = int(total_seconds) % 60
		var centiseconds = int((total_seconds - int(total_seconds)) * 100)  # Centièmes de seconde
		
		# Formater le temps final sous la forme "minutes:secondes.centièmes"
		var formatted_time = "%d:%02d.%02d" % [minutes, seconds, centiseconds]
		
		# Afficher le temps final depuis la variable globale
		label.text = formatted_time

func _on_main_menu_pressed():
	print("Quit button pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Main_Menu.tscn")
