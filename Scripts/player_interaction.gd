extends Area2D

@onready var player = $Player
@onready var collision_shape_2d = $CameraLimiters/CameraLimiter1/CollisionShape2D

@onready var camera = $"../Camera2D"  # Ajustez le chemin selon votre scène

func _ready():
	# Vérifiez que player est bien initialisé
	if player == null:
		print("Player is null in _ready(). Check the path!")
	else:
		print("Player initialized successfully:", player.name)

	# Affichez la hiérarchie des nœuds pour déboguer
	print("Current node path: ", get_path())
	print("Trying to access Player at path: ", $Player.get_path() if $Player else "Player not found!")

func _on_area_entered(area):
	# Vérifiez que player et camera ne sont pas null
	if player == null:
		print("Player is not initialized!")
		return
	if camera == null:
		print("Camera is not initialized!")
		return

	# Vérifiez que l'area est bien un CameraLimiter
	if area is CameraLimiter:
		# Assurez-vous que player a une propriété camera
		if player.has_method("set_camera"):
			player.set_camera(camera)
		else:
			print("Player does not have a 'camera' property or method!")
