extends Node2D

@onready var main_menu = $"CanvasLayer/Main Menu"

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
