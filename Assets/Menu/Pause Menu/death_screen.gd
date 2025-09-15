extends Control

signal resume_requested

@onready var death_screen: Control = $"."
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var quit: CustomButton = $CanvasLayer/Quit
@onready var resume: CustomButton = $CanvasLayer/Resume
@onready var button_quit_anim: AnimatedSprite2D = $CanvasLayer/Quit/ButtonQuitAnim
@onready var button_play_anim: AnimatedSprite2D = $CanvasLayer/Resume/ButtonPlayAnim

func _ready() -> void:
	animation_player.play("fade_in")
	
	quit.pressed.connect(_on_quit_pressed)
	
	# Connecter les signaux pour les animations des AnimatedSprite2D
	quit.focus_entered.connect(_on_quit_focus_entered)
	
	# Configuration de la navigation manette
	setup_controller_navigation()

func setup_controller_navigation():
	# Définir le bouton par défaut au focus
	resume.grab_focus()

func _on_resume_focus_entered() -> void:
	# Lancer l'animation de l'AnimatedSprite2D
	button_play_anim.play("Play")

func _on_resume_focus_exited() -> void:
	# Remettre à la première frame
	button_play_anim.stop()
	button_play_anim.frame = 0

func _on_quit_focus_entered() -> void:
	# Lancer l'animation de l'AnimatedSprite2D
	button_quit_anim.play("Quit")

func _on_quit_focus_exited() -> void:
	# Arrêter l'animation puis remettre à la première frame
	button_quit_anim.stop()
	button_quit_anim.frame = 0

func _on_resume_pressed() -> void:
	emit_signal("resume_requested")  # Émettre le signal
	queue_free()  # Supprimer le menu pause

func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MENU/main_menu_V2.tscn")
