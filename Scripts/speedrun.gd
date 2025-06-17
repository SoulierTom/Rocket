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

func _ready():
	add_to_group("speedrun_timer")
	
	if not Global.timer_initialized:
		reset_timer()
		Global.timer_initialized = true
	else:
		time = Global.speedrun_time

func _physics_process(delta):
	# Le timer continue TOUJOURS de tourner
	time += delta
	Global.speedrun_time = time
	
	# Gestion du clignotement
	if is_blinking:
		handle_blinking(delta)
	
	# Mise à jour de l'affichage
	update_ui()

func handle_blinking(delta: float):
	"""Gère le clignotement pendant la transition"""
	blink_timer += delta
	
	# Calculer si le label doit être visible ou invisible
	var cycle_time = fmod(blink_timer, blink_interval * 2)
	var should_be_visible = cycle_time < blink_interval
	
	if label:
		label.visible = should_be_visible
	
	# Arrêter le clignotement après 0.8 secondes
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
	update_ui()

func freeze_display():
	"""Fige l'affichage sur le temps actuel"""
	display_frozen = true
	frozen_time = time

func unfreeze_display():
	"""Remet l'affichage en temps réel"""
	display_frozen = false

func start_blinking():
	"""Démarre le clignotement"""
	is_blinking = true
	blink_timer = 0.0

func stop_blinking():
	"""Arrête le clignotement"""
	is_blinking = false
	blink_timer = 0.0
	if label:
		label.visible = true

func update_ui():
	if not label:
		return
	
	# Choisir quel temps afficher
	var display_time = frozen_time if display_frozen else time
	
	# Formatage du temps
	var minutes = int(display_time) / 60
	var seconds = int(display_time) % 60
	var centiseconds = int((display_time - int(display_time)) * 100)
	label.text = "%02d:%02d.%02d" % [minutes, seconds, centiseconds]

# Fonction appelée depuis l'extérieur pour figer l'affichage et faire clignoter
func trigger_level_complete():
	freeze_display()
	start_blinking()
