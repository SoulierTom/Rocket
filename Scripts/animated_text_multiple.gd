# Version alternative utilisant _process pour plus de fiabilité
extends Node2D

@onready var label1 = $Label1
@onready var label2 = $Label2  
@onready var label3 = $Label3
@onready var animation_player = $AnimationPlayerMultiple

var player_in_area = false
var current_message = 0
var max_messages = 2
var animation_finished = false
var input_pressed_last_frame = false

func _ready():
	$Area2D.body_entered.connect(_on_body_entered)
	animation_player.animation_finished.connect(_on_animation_finished)
	hide_all_labels()

func _process(_delta):
	if player_in_area and animation_finished:
		var input_pressed = Input.is_action_pressed("ok")
		
		# Détecter le passage de non-pressé à pressé (edge detection)
		if input_pressed and not input_pressed_last_frame:
			print("OK pressé - Animation terminée, passage au suivant")
			advance_message()
		
		input_pressed_last_frame = input_pressed
	else:
		input_pressed_last_frame = false

func _on_animation_finished(anim_name: String):
	"""Appelé quand une animation se termine"""
	print("Animation terminée:", anim_name)
	animation_finished = true
	
func _on_body_entered(body):
	if body.name == "Player" or body.is_in_group("player"):
		player_in_area = true
		current_message = 0
		animation_finished = false
		show_message(current_message)


func advance_message():
	current_message += 1
	animation_finished = false  # Nouvelle animation commence
	
	if current_message <= max_messages:
		show_message(current_message)
	else:
		animation_finished = true

func show_message(message_index: int):
	hide_all_labels()
	
	match message_index:
		0:
			label1.visible_ratio = 0.0
			label1.visible = true
			animation_player.play("Show_Text_1")
		1:
			label2.visible_ratio = 0.0
			label2.visible = true
			animation_player.play("Show_Text_2")
		2:
			label3.visible_ratio = 0.0
			label3.visible = true
			animation_player.play("Show_Text_3")

func hide_all_labels():
	label1.visible = false
	label2.visible = false
	label3.visible = false
