extends Node2D

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
