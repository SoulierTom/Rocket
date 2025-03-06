extends Node2D

@onready var camera: Camera = $Player/Camera

func _ready():
	if camera:
		# Décaler la caméra vers le bas (par exemple, de 1000 pixels)
		camera.offset.y += 75
	else:
		print("Erreur : La caméra n'a pas été assignée.")
