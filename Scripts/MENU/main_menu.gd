extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var play: CustomButton = $CanvasLayer/Play
@onready var quit: CustomButton = $CanvasLayer/Quit
@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var button_play_anim: AnimatedSprite2D = $CanvasLayer/Play/ButtonPlayAnim
@onready var button_quit_anim: AnimatedSprite2D = $CanvasLayer/Quit/ButtonQuitAnim
@onready var main_theme: AudioStreamPlayer2D = $MainTheme

func _ready() -> void:
	
	await get_tree().create_timer(0.3).timeout
	MusicManager.restore_volume(0.8)
	animation_player.play("fade_in")
	
	# Connecter les signaux des boutons
	play.pressed.connect(_on_play_pressed)
	quit.pressed.connect(_on_quit_pressed)
	
	# Connecter les signaux pour les animations des AnimatedSprite2D
	play.focus_entered.connect(_on_play_focus_entered)
	play.focus_exited.connect(_on_play_focus_exited)
	quit.focus_entered.connect(_on_quit_focus_entered)
	quit.focus_exited.connect(_on_quit_focus_exited)
	
	# Configuration de la navigation manette
	setup_controller_navigation()
	
	if main_theme.stream:
		MusicManager.play_music(main_theme.stream, 1.0)  # Fade in de 2 secondes

func setup_controller_navigation():
	# Définir l'ordre de navigation
	play.focus_neighbor_bottom = quit.get_path()
	quit.focus_neighbor_top = play.get_path()
	
	# Navigation horizontale (pour éviter les bugs)
	play.focus_neighbor_left = play.get_path()
	play.focus_neighbor_right = play.get_path()
	quit.focus_neighbor_left = quit.get_path()
	quit.focus_neighbor_right = quit.get_path()
	
	# Définir le bouton par défaut au focus
	play.grab_focus()

func _on_play_focus_entered() -> void:
	# Lancer l'animation de l'AnimatedSprite2D
	button_play_anim.play("Play")

func _on_play_focus_exited() -> void:
	# Remettre à la première frame
	button_play_anim.frame = 0

func _on_quit_focus_entered() -> void:
	# Lancer l'animation de l'AnimatedSprite2D
	button_quit_anim.play("Quit")

func _on_quit_focus_exited() -> void:
	# Remettre à la première frame
	button_quit_anim.frame = 0

func _on_play_pressed() -> void:
	TransitionScreen.transition()
	await TransitionScreen.on_transition_finished
	MusicManager.stop_music(0.4)  # Durée du fade out (ajustez selon la durée de votre transition)
	get_tree().change_scene_to_file("res://Levels/From_Godot/New Levels/Level_1.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func delete():
	color_rect.queue_free()
