extends CanvasLayer

signal on_transition_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer
@onready var timer_label = $TimerLabel

var speedrun_timer: CanvasLayer = null

func _ready():
	color_rect.visible = false
	timer_label.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	# Récupération sécurisée du timer
	speedrun_timer = get_tree().get_first_node_in_group("SpeedrunTimer")

func _on_animation_finished(anim_name):
	match anim_name:
		"fade_to_black":
			on_transition_finished.emit()
			animation_player.play("fade_to_normal")
		"fade_to_normal":
			color_rect.visible = false
			timer_label.visible = false
			# Réafficher le timer seulement à la fin complète
			if speedrun_timer:
				speedrun_timer.visible = true

func transition():
	if speedrun_timer:
		speedrun_timer.visible = false  # Cache immédiatement le timer speedrun
	
	color_rect.visible = true
	timer_label.visible = true
	show_time(Global.speedrun_time)
	animation_player.play("fade_to_black")

func show_time(time: float):
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var centiseconds = int((time - int(time)) * 100)
	timer_label.text = "%02d:%02d.%02d" % [minutes, seconds, centiseconds]
