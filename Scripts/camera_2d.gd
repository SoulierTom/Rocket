extends Camera2D

@export var base_width: int = 256
@export var base_height: int = 144

func _ready():
	update_camera_ratio()
	get_viewport().size_changed.connect(update_camera_ratio)

func update_camera_ratio():
	var viewport_size = get_viewport_rect().size
	var target_aspect = float(base_width) / base_height
	var current_aspect = float(viewport_size.x) / viewport_size.y

	if current_aspect > target_aspect:
		zoom.x = zoom.y * (current_aspect / target_aspect)
	else:
		zoom.y = zoom.x * (target_aspect / current_aspect)
