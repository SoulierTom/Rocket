extends Node2D

@onready var Anim = $AnimationPlayer
var animation_finished = false

func _ready() -> void:
	
	$Main_Text.visible_ratio = 0.0
	$FmodTypeScreen.play()
	$AnimationPlayer.play('Display_Text')
	$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	if animation_finished:
		$FmodTypeScreen.stop()
	
func _on_animation_finished(anim_name: StringName):
	print("anim finished")
	animation_finished = true
