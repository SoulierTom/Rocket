# SpeedrunTimer.gd
extends Control

var time: float = 0.0
var display_frozen: bool = false
var frozen_time: float = 0.0
var is_blinking: bool = false
var blink_timer: float = 0.0
var blink_duration: float = 0.8
var blink_interval: float = 0.1

@onready var label: Label = $CanvasLayer/Label
@onready var centieme_label: Label = $CanvasLayer/centieme

func _ready():
	add_to_group("speedrun_timer")
	
	if not Global.timer_initialized:
		reset_timer()
		Global.timer_initialized = true
	else:
		time = Global.speedrun_time

func _physics_process(delta):
	time += delta
	Global.speedrun_time = time
	
	if is_blinking:
		handle_blinking(delta)
	
	update_ui()

func handle_blinking(delta: float):
	blink_timer += delta
	var cycle_time = fmod(blink_timer, blink_interval * 2)
	var should_be_visible = cycle_time < blink_interval
	
	if label:
		label.visible = should_be_visible
	if centieme_label:
		centieme_label.visible = should_be_visible
	
	if blink_timer >= blink_duration:
		stop_blinking()

func reset_timer():
	time = 0.0
	Global.speedrun_time = 0.0
	display_frozen = false
	frozen_time = 0.0
	is_blinking = false
	blink_timer = 0.0
	if label:
		label.visible = true
	if centieme_label:
		centieme_label.visible = true
	update_ui()

func freeze_display():
	display_frozen = true
	frozen_time = time

func unfreeze_display():
	display_frozen = false

func start_blinking():
	is_blinking = true
	blink_timer = 0.0

func stop_blinking():
	is_blinking = false
	blink_timer = 0.0
	if label:
		label.visible = true
	if centieme_label:
		centieme_label.visible = true

func update_ui():
	if not label or not centieme_label:
		return
	
	var display_time = frozen_time if display_frozen else time
	
	var minutes = int(display_time) / 60
	var seconds = int(display_time) % 60
	var centiseconds = int((display_time - int(display_time)) * 100)
	
	label.text = "%02d:%02d" % [minutes, seconds]
	centieme_label.text = ".%02d" % centiseconds

func trigger_level_complete():
	freeze_display()
	start_blinking()
