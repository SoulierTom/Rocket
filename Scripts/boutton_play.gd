extends Area2D

@export var scale_speed: float = 2.0
@export var scale_factor: float = 1.2
@export var scale_curve: Curve
@export var click_curve: Curve
@export var click_speed: float = 8.0
@export var click_scale: float = 0.9

@onready var animated_sprite = $AnimatedSprite2D
@onready var blip: AudioStreamPlayer2D = $"../blip"
@onready var focus_button: Button = $FocusButton  # Bouton invisible pour support manette

const MAIN = preload("res://Levels/From_Godot/Test_Level_1.tscn")

var scale_tween: Tween
var click_tween: Tween
var is_hovering: bool = false
var animation_playing: bool = false
var clicking: bool = false

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

	focus_button.pressed.connect(_on_focus_button_pressed)
	focus_button.focus_mode = Control.FOCUS_ALL
	focus_button.grab_focus()  # Donne le focus au démarrage

	setup_initial_state()

func _unhandled_input(event):
	if not is_hovering:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		start_click_animation()
		get_viewport().set_input_as_handled()

func _on_focus_button_pressed():
	if not clicking:
		start_click_animation()

func setup_initial_state():
	if animated_sprite.sprite_frames:
		animated_sprite.sprite_frames.set_animation_loop("default", false)

	animated_sprite.frame = 0
	animated_sprite.stop()
	scale = Vector2.ONE
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _on_mouse_entered():
	is_hovering = true
	blip.play(0.3)
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

	if not animation_playing and not clicking:
		start_hover_animation()
	elif not clicking:
		scale_up()

func _on_mouse_exited():
	is_hovering = false
	blip.stop()
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

	if clicking:
		return

	animated_sprite.frame = 0
	animated_sprite.stop()
	animation_playing = false
	scale_down()

func start_click_animation():
	if clicking:
		return
	
	clicking = true

	if click_tween:
		click_tween.kill()

	click_tween = create_tween()
	click_tween.set_ease(Tween.EASE_OUT)
	click_tween.set_trans(Tween.TRANS_BACK)

	if click_curve:
		click_tween.tween_method(_apply_click_curve, 0.0, 1.0, 1.0 / click_speed)
	else:
		var tween_sequence = click_tween.tween_property(self, "scale", Vector2.ONE * click_scale, 0.1)
		tween_sequence.tween_property(self, "scale", Vector2.ONE * scale_factor if is_hovering else Vector2.ONE, 0.1)

	await click_tween.finished
	clicking = false
	load_main_scene()

func _apply_click_curve(progress: float):
	var curve_value = click_curve.sample(progress)
	var base_scale = scale_factor if is_hovering else 1.0
	var click_offset = (base_scale - click_scale) * curve_value
	var target_scale = base_scale - click_offset
	scale = Vector2.ONE * target_scale

func load_main_scene():
	Global.speedrun_time = 0.0
	Global.timer_initialized = false
	LevelManager.current_level_index = 0
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	get_tree().change_scene_to_file("res://Levels/From_Godot/Test_Level_1.tscn")

func start_hover_animation():
	animation_playing = true
	animated_sprite.play()
	scale_up()
	await animated_sprite.animation_finished
	animation_playing = false

func scale_up():
	if scale_tween:
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.set_trans(Tween.TRANS_BACK)

	if scale_curve:
		scale_tween.tween_method(_apply_scale_curve, 0.0, 1.0, 1.0 / scale_speed)
	else:
		scale_tween.tween_property(self, "scale", Vector2.ONE * scale_factor, 1.0 / scale_speed)

func scale_down():
	if scale_tween:
		scale_tween.kill()

	scale_tween = create_tween()
	scale_tween.set_ease(Tween.EASE_OUT)
	scale_tween.set_trans(Tween.TRANS_BACK)

	if scale_curve:
		scale_tween.tween_method(_apply_scale_curve_reverse, 0.0, 1.0, 1.0 / scale_speed)
	else:
		scale_tween.tween_property(self, "scale", Vector2.ONE, 1.0 / scale_speed)

func _apply_scale_curve(progress: float):
	var curve_value = scale_curve.sample(progress)
	var target_scale = 1.0 + (scale_factor - 1.0) * curve_value
	scale = Vector2.ONE * target_scale

func _apply_scale_curve_reverse(progress: float):
	var _curve_value = scale_curve.sample(1.0 - progress)
	var current_scale = scale.x
	var target_scale = current_scale - (current_scale - 1.0) * progress
	scale = Vector2.ONE * target_scale

func trigger_animation():
	if not animation_playing:
		start_hover_animation()
