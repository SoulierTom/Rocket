extends Area2D

@onready var player = $".."  # InteractionBox est un enfant de Player
@onready var collision_shape_2d = $CollisionShape2D  # CollisionShape2D est un enfant de InteractionBox
@onready var camera = $"../Camera"  # Camera est un enfant de Player

func _ready():
	if player == null:
		print("Player is null in _ready(). Check the path!")
	else:
		print("Player initialized successfully:", player.name)

	if camera == null:
		print("Camera is null in _ready(). Check the path!")
	else:
		print("Camera initialized successfully:", camera.name)

	if collision_shape_2d == null:
		print("CollisionShape2D is null in _ready(). Check the path!")
	else:
		print("CollisionShape2D initialized successfully:", collision_shape_2d.name)

func _on_area_entered(area):
	if player == null:
		print("Player is not initialized!")
		return
	if camera == null:
		print("Camera is not initialized!")
		return

	if area is CameraLimiter:
		if player.has_method("set_camera"):
			player.set_camera(camera)
		else:
			print("Player does not have a 'camera' property or method!")
