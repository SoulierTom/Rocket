extends Area2D

class_name CameraLimiter

enum LimitX {NONE, LEFT, RIGHT}
enum LimitY {NONE, TOP, BOTTOM}

const MAX_VAL = 100000

@export var limit_x: LimitX = LimitX.NONE
@export var limit_y: LimitY = LimitY.NONE

@onready var marker = $LimitPosition

func get_limit_top():
	if limit_y != LimitY.TOP:
		return -MAX_VAL
	return marker.global_position.y

func get_limit_bottom():
	if limit_y != LimitY.BOTTOM:
		return MAX_VAL
	return marker.global_position.y

func get_limit_left():
	if limit_x != LimitX.LEFT:
		return -MAX_VAL
	return marker.global_position.x

func get_limit_right():
	if limit_x != LimitX.LEFT:
		return MAX_VAL
	return marker.global_position.x
