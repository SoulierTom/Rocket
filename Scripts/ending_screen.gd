extends Node2D

@onready var ending_screen: Node2D = $"."

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
	var label = $CanvasLayer/Label
	if label:
		# Convertir le temps en minutes et secondes
		var minutes = int(Global.speedrun_time) / 60
		var seconds = int(Global.speedrun_time) % 60

		# Formater le temps final sous la forme "minutes:secondes"
		var formatted_time = "%d:%02d" % [minutes, seconds]
		
		# Afficher le temps final depuis la variable globale
		label.text = "Temps final : " + formatted_time + " minutes"

func _on_main_menu_pressed():
	print("Quit button pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Main_Menu.tscn")
