extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Main_Text.visible_ratio = 0.0
	$AnimationPlayer.play('Display_Text')
