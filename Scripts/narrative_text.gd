extends Node2D

@onready var display_text = $DisplayText

func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ok"):
		if not display_text.animation_finished :
			print("skip text")
			display_text.Anim.seek(6.0)
			display_text.animation_finished = true
		else:
			LevelManager.go_to_next_level()
