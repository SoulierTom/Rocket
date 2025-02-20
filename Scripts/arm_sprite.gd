extends Sprite2D

@onready var player = $".."

# Variables propres au mouvement du bras
var is_using_gamepad = false
var last_joystick_vector = Vector2.RIGHT

func _process(_delta):

	# Si le gamepad est utilisé, ajuster la position du bras en fonction du joystick
	var mouse_pos = get_global_mouse_position()
	var joystick_vector = Input.get_vector("Look_Left", "Look_Right", "Look_Up", "Look_Down")

	if is_using_gamepad:
		if joystick_vector.length() > 0.1:
			Global.target_pos = player.position + joystick_vector * 500
			last_joystick_vector = joystick_vector
			look_at(Global.target_pos)
		else:
			Global.target_pos = player.position + last_joystick_vector * 500
			look_at(Global.target_pos)
	else:
		Global.target_pos = mouse_pos
		look_at(Global.target_pos)
