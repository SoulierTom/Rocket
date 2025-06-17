extends Camera2D

class_name Camera

@export var target: NodePath
@export var offset_y: float = 0.0
@export var zoom_level: Vector2 = Vector2(2, 2)

@export_group("Bounds Settings")
@export var bounds_enabled: bool = true
@export var bounds_node_path: NodePath

@export_group("Follow Settings")
@export var follow_speed: float = 2.0
@export var smoothing_enabled: bool = true
@export var follow_delay: float = 1.0
@export var offset_horizontal: float = 40.0
@export var offset_transition_speed: float = 2.0

@export_group("Shake Settings")
@export var shake_intensity: float = 4.0
@export var shake_frequency: float = 2.0
@export var shake_enabled: bool = true

@export_group("Explosion Shake Settings")
@export var explosion_shake_intensity: float = 3.0
@export var explosion_shake_duration: float = 0.2
@export var explosion_shake_enabled: bool = true

@onready var player = get_node(target) if target != NodePath() else null
var bounds_node: CameraBounds = null
var shake_offset: Vector2 = Vector2.ZERO
var time_elapsed: float = 0.0
var target_position: Vector2

var movement_timer: float = 0.0
var current_direction: float = 0.0
var target_offset_x: float = 0.0
var current_offset_x: float = 0.0

var base_offset_y: float = 0.0
var dynamic_offset_y: float = 0.0
var current_total_offset_y: float = 0.0
var target_total_offset_y: float = 0.0

var previous_player_impulsed: bool = false
var explosion_shake_active: bool = false
var explosion_shake_timer: float = 0.0
var explosion_shake_current_intensity: float = 0.0

func _ready():
	if target == NodePath():
		player = get_tree().get_first_node_in_group("Player")
	else:
		player = get_node(target)
	
	if not player:
		return
	
	_find_bounds_node()
	
	base_offset_y = offset_y
	current_total_offset_y = offset_y
	target_total_offset_y = offset_y
	zoom = zoom_level
	
	if Global.has_method("get") or "player_impulsed" in Global:
		previous_player_impulsed = Global.player_impulsed
	
	await get_tree().process_frame
	
	target_total_offset_y = base_offset_y + dynamic_offset_y
	current_total_offset_y = target_total_offset_y
	offset_y = current_total_offset_y
	
	if player:
		global_position = player.global_position + Vector2(0, offset_y)
		target_position = global_position
		
		if bounds_enabled and bounds_node:
			target_position = _apply_bounds_to_position(target_position)
			global_position = target_position
		
		current_offset_x = 0.0
		target_offset_x = 0.0

func _find_bounds_node():
	if bounds_node_path != NodePath():
		bounds_node = get_node(bounds_node_path) as CameraBounds
	else:
		bounds_node = get_tree().get_first_node_in_group("camera_bounds") as CameraBounds
	
	if bounds_node and not bounds_node.is_connected("bounds_changed", _on_bounds_changed):
		bounds_node.connect("bounds_changed", _on_bounds_changed)

func _on_bounds_changed():
	if bounds_enabled and bounds_node:
		target_position = _apply_bounds_to_position(target_position)

func _process(delta):
	if not player:
		return
	
	time_elapsed += delta
	
	_check_explosion_trigger()
	_update_explosion_shake(delta)
	_update_offset_y(delta)
	_detect_player_movement(delta)
	_calculate_target_position()
	
	if bounds_enabled and bounds_node:
		target_position = _apply_bounds_to_position(target_position)
	
	var next_position: Vector2
	if smoothing_enabled:
		next_position = global_position.lerp(target_position, follow_speed * delta)
	else:
		next_position = target_position
	
	if bounds_enabled and bounds_node:
		next_position = _apply_bounds_to_position(next_position)
	
	global_position = next_position
	
	if shake_enabled:
		_apply_shake()

func _check_explosion_trigger():
	if Global.has_method("get") or "player_impulsed" in Global:
		var current_player_impulsed = Global.player_impulsed
		
		if not previous_player_impulsed and current_player_impulsed and explosion_shake_enabled:
			_trigger_explosion_shake()
		
		previous_player_impulsed = current_player_impulsed

func _trigger_explosion_shake():
	explosion_shake_active = true
	explosion_shake_timer = 0.0
	explosion_shake_current_intensity = explosion_shake_intensity

func _update_explosion_shake(delta):
	if not explosion_shake_active:
		return
	
	explosion_shake_timer += delta
	var progress = explosion_shake_timer / explosion_shake_duration
	
	if progress >= 1.0:
		explosion_shake_active = false
		explosion_shake_current_intensity = 0.0
	else:
		explosion_shake_current_intensity = explosion_shake_intensity * pow(1.0 - progress, 2.0)

func _apply_shake():
	var total_shake_offset = Vector2.ZERO
	
	var normal_shake_x = sin(time_elapsed * shake_frequency) * shake_intensity
	var normal_shake_y = cos(time_elapsed * shake_frequency * 0.7) * shake_intensity * 0.5
	total_shake_offset += Vector2(normal_shake_x, normal_shake_y)
	
	if explosion_shake_active:
		var explosion_shake_x = (randf() - 0.5) * 2.0 * explosion_shake_current_intensity
		var explosion_shake_y = (randf() - 0.5) * 2.0 * explosion_shake_current_intensity
		total_shake_offset += Vector2(explosion_shake_x, explosion_shake_y)
	
	shake_offset = total_shake_offset
	offset = shake_offset

func _apply_bounds_to_position(pos: Vector2) -> Vector2:
	if not bounds_node or bounds_node.get_point_count() < 2:
		return pos
	
	var bounds_rect = bounds_node.get_bounds_rect()
	if bounds_rect.size == Vector2.ZERO:
		return pos
	
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_size = viewport_size / zoom
	var half_camera_size = camera_size / 2.0
	
	var min_x = bounds_rect.position.x + half_camera_size.x
	var max_x = bounds_rect.position.x + bounds_rect.size.x - half_camera_size.x
	var min_y = bounds_rect.position.y + half_camera_size.y
	var max_y = bounds_rect.position.y + bounds_rect.size.y - half_camera_size.y
	
	if max_x < min_x:
		var center_x = (bounds_rect.position.x + bounds_rect.position.x + bounds_rect.size.x) / 2
		min_x = center_x
		max_x = center_x
	if max_y < min_y:
		var center_y = (bounds_rect.position.y + bounds_rect.position.y + bounds_rect.size.y) / 2
		min_y = center_y
		max_y = center_y
	
	return Vector2(clamp(pos.x, min_x, max_x), clamp(pos.y, min_y, max_y))

func set_bounds_node(bounds: CameraBounds):
	bounds_node = bounds
	if bounds_node and not bounds_node.is_connected("bounds_changed", _on_bounds_changed):
		bounds_node.connect("bounds_changed", _on_bounds_changed)

func set_bounds_enabled(enabled: bool):
	bounds_enabled = enabled

func _update_offset_y(delta):
	target_total_offset_y = base_offset_y + dynamic_offset_y
	current_total_offset_y = lerp(current_total_offset_y, target_total_offset_y, offset_transition_speed * delta)
	offset_y = current_total_offset_y

func _detect_player_movement(delta):
	var is_moving_right = Input.is_action_pressed("Move_Right")
	var is_moving_left = Input.is_action_pressed("Move_Left")
	
	var new_direction = 0.0
	if is_moving_right:
		new_direction = 1.0
	elif is_moving_left:
		new_direction = -1.0
	
	if new_direction != current_direction:
		current_direction = new_direction
		movement_timer = 0.0
		
		if current_direction > 0:
			target_offset_x = offset_horizontal
		elif current_direction < 0:
			target_offset_x = -offset_horizontal
		else:
			target_offset_x = 0.0
	
	if current_direction != 0:
		movement_timer += delta
	else:
		movement_timer = 0.0

func _calculate_target_position():
	current_offset_x = lerp(current_offset_x, target_offset_x, offset_transition_speed * get_process_delta_time())
	var base_position = player.global_position + Vector2(0, offset_y)
	target_position = base_position + Vector2(current_offset_x, 0)

func trigger_shake(intensity: float, duration: float):
	var tween = create_tween()
	var original_intensity = shake_intensity
	shake_intensity = intensity
	tween.tween_method(_reduce_shake, intensity, original_intensity, duration)

func _reduce_shake(value: float):
	shake_intensity = value

func trigger_explosion_shake_manual():
	_trigger_explosion_shake()

func set_dynamic_offset_y(new_offset: float):
	dynamic_offset_y = new_offset
	if not is_inside_tree() or get_tree().current_scene.get_tree().current_frame <= 2:
		set_dynamic_offset_y_instant(new_offset)
	else:
		if movement_timer < follow_delay:
			_force_position_update()

func set_dynamic_offset_y_instant(new_offset: float):
	dynamic_offset_y = new_offset
	current_total_offset_y = base_offset_y + dynamic_offset_y
	offset_y = current_total_offset_y
	_force_position_update()

func _force_position_update():
	if player:
		target_position = player.global_position + Vector2(0, offset_y)
		if bounds_enabled and bounds_node:
			target_position = _apply_bounds_to_position(target_position)
		global_position = target_position

func add_temp_offset_y(temp_offset: float):
	dynamic_offset_y += temp_offset

func reset_dynamic_offset_y():
	dynamic_offset_y = 0.0

func get_current_offset_y() -> float:
	return current_total_offset_y
