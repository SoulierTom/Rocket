extends Area2D

@onready var player = $".."
@onready var camera_limit_manager = $"../Camera/CameraLimitManager"

func _ready():
	if player == null:
		print("Player is null in _ready(). Check the path!")
	else:
		print("Player initialized successfully:", player.name)

	if camera_limit_manager == null:
		print("CameraLimitManager is null in _ready(). Check the path!")
	else:
		print("CameraLimitManager initialized successfully:", camera_limit_manager.name)

func _on_area_entered(area):
	if player == null:
		print("Player is not initialized!")
		return

	if camera_limit_manager == null:
		print("CameraLimitManager is not initialized!")
		return

	if area is CameraLimiter:
		print("CameraLimiter detected!")
		camera_limit_manager.set_limiter(area)
