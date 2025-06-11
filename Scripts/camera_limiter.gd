extends Area2D

class_name CameraLimiter

const MAX_VAL = 100000

@export var limit_x = "CameraBorderX.None"
@export var limit_y = "CameraBorderY.None"

@onready var marker: CameraLimiter = $"."


func get_limit_top():
	if limit_y != "CameraBorderY.Top":
		return -MAX_VAL
	return marker.global_position.y

func get_limit_bottom():
	if limit_y != "CameraBorderY.Bottom":
		return MAX_VAL
	return marker.global_position.y

func get_limit_left():
	if limit_x != "CameraBorderX.Left":
		return -MAX_VAL
	return marker.global_position.x

func get_limit_right():
	if limit_x != "CameraBorderX.Right":
		return MAX_VAL
	return marker.global_position.x
