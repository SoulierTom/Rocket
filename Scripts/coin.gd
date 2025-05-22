extends Node2D


var is_on_screen = false
var screen_size = Vector2(DisplayServer.window_get_size())
var screen_position = Vector2(0, 0)
var shockwave = ""


func _ready() -> void:
	shockwave = get_node("../Canvas_layer/ShockwaveShader").material

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	is_on_screen = true

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	is_on_screen = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_on_screen == true:
		#screen_position = get_node("../Player/Camera").global_position
		#var origine_screen = (screen_position - screen_size/2)
		#var position_on_screen = position - origine_screen
		#var position_normal = (position_on_screen / screen_size)
		#shockwave.set_shader_parameter("position", position_normal)
		#shockwave.set_shader_parameter("radius", 0.8)
		#print(position_normal)
		pass
