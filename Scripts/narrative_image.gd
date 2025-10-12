extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ok"):
		set_process(false)  # Désactive _process pour bloquer tout input ultérieur
		LevelManager.go_to_next_level()
