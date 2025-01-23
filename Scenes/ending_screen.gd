extends Node2D

func _ready():
	# Récupérer le Label
	var label = $CanvasLayer/Label
	if label:
		# Afficher le temps final depuis la variable globale
		label.text = "Temps final : " + str(Global.speedrun_time) + " secondes"
