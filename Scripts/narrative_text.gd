extends Node2D

@onready var display_text = $DisplayText

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ok"):
		if not display_text.animation_finished:
			print("skip text")
			display_text.Anim.seek(13.0)
			display_text.animation_finished = true
		else:
			set_process(false)  # Désactive _process pour bloquer tout input ultérieur
			LevelManager.go_to_next_level()
