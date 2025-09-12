extends CharacterBody2D

# Variables de mouvement du Player
var SPEED = 150
var ACCELERATION = 250.0
var FRICTION = 800.0
var GRAVITY = 1500.0
var max_fall_speed : float = 250

var is_wall_sliding := false
const wall_slide_gravity := 0

var fall_time := 0.0
const FALL_ACCEL_TIME := 1.0  # durée avant chute pleine vitesse
var bonk_freeze_timer: float = 0.0
const BONK_FREEZE_TIME := 0.24  # Ajuste pour le feeling

var gravity_scale = 1.0
var was_going_up = false
var time_in_fall = 0.0

@onready var arm = $Arm
var arm_offset_x: float = 0.85

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

@onready var pause_menu = preload("res://Scenes/pause_menu.tscn")
var pause_instance = null

# Ajoutez une variable pour stocker la référence à la caméra
var camera: Camera2D = null

# Ajoutez une référence au CanvasLayer
@onready var canvas_layer = $CanvasLayer

func _physics_process(delta: float) -> void:

	if Input.is_action_just_pressed("Reset_Chapter"):
		get_tree().change_scene_to_file("res://Levels/From_Godot/Test_Level_1.tscn")
		Global.speedrun_time = 0
		
	if Input.is_action_just_pressed("Reset_Level"):
		get_tree().reload_current_scene()
		
	# Toggle des vibrations
	if Input.is_action_just_pressed("toggle_vibration"):
		Global.VBR = !Global.VBR

	var horizontal_input := Input.get_vector("Move_Left", "Move_Right","Move_Up", "Move_Down")
	
	if bonk_freeze_timer > 0.0:
		bonk_freeze_timer -= delta
		velocity.y *= 0.9
		velocity.x *= 0.9  
	
	if is_on_floor():
		Global.player_impulsed = false
		fall_time = 0.0
		Global.current_ammo = Global.magazine_size
	else:
		fall_time += delta
		velocity.y += add_gravity() * delta
	
	if is_on_ceiling():
		bonk_freeze_timer = BONK_FREEZE_TIME  # Active le freeze
		# Fmod Son : lancement Event Bonk depuis l'Emitter sur Playernode
		$FmodBonk.play()
		
	wall_slide(delta)
		
	if not Global.player_impulsed:
		if is_on_floor():
			if abs(horizontal_input.x) >= 0.1:
				if sign(velocity.x) != sign(horizontal_input.x):
					velocity.x = move_toward(velocity.x, 0, FRICTION * delta * 10)  #Au sol, fais demi-tour rapidement
				velocity.x = move_toward(velocity.x, sign(horizontal_input.x) * SPEED , ACCELERATION * delta) #Au sol, avance de manière accéléré
			else:
				velocity.x = move_toward(velocity.x, 0, FRICTION * delta * 2) #Au sol, Friction
		else:
			if abs(horizontal_input.x) >= 0.1:
				if sign(velocity.x) != sign(horizontal_input.x):
					velocity.x = move_toward(velocity.x, 0, FRICTION * delta * 1.5)  #En sautant, fais demi-tour rapidement
				velocity.x = move_toward(velocity.x, sign(horizontal_input.x) * SPEED, ACCELERATION * delta * 2 ) #En sautant, avance de manière accéléré 
			else:
				velocity.x = move_toward(velocity.x, 0, (FRICTION * delta) * 0.25) #en l'air, Friction
	else:
		if abs(horizontal_input.x) >= 0.1:
			if sign(velocity.x) != sign(horizontal_input.x):
					velocity.x = move_toward(velocity.x, 0, FRICTION * delta * 0.1) #Propulsé
			velocity.x = move_toward(velocity.x, sign(horizontal_input.x) * SPEED, ACCELERATION * delta * 1)
		else :
			velocity.x = move_toward(velocity.x, 0, (FRICTION * delta) * 0.1)
	
	if is_on_floor():
		if horizontal_input.y > 0.95:
			position.y += 1
	
	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed
	
	move_and_slide()
	
	var current_frame = animated_sprite.frame
	var dir_arm = (Global.target_pos - arm.global_position).normalized()
	
	if is_on_floor():
		if abs(horizontal_input.x) < 0.1:
			if dir_arm.x > 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("idle_left")
		else:
			if dir_arm.x > 0:
				animated_sprite.play("run")
				if current_frame >= 0 and current_frame < 1:
					$FmodWalk.play_one_shot()
				# $walk_sound.play()
				#if current_frame >= 2 and current_frame < 3:
					# $walk_sound.play()
					#$FmodWalk.play_one_shot()
			else:
				animated_sprite.play("run_left")
				if current_frame >= 0 and current_frame < 1:
					$FmodWalk.play_one_shot()
					# $walk_sound.play()
				#if current_frame >= 2 and current_frame < 3:
					# $walk_sound.play()
					#$FmodWalk.play_one_shot()
	else:
		if dir_arm.x > 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("jump_left")

	if Input.is_action_just_pressed("ui_cancel"):
		if pause_instance == null:
			pause_game()
		else:
			resume_game()

func add_gravity() -> float:
	var fall_progress: float = clamp(fall_time / FALL_ACCEL_TIME, 0.0, 1.0)
	var fall_ease := ease_out(fall_progress)
	
	if Global.player_impulsed :
		var impulsed_modifier = clamp(velocity.length() / 275.0, 0.15, 1.0)
		return GRAVITY * impulsed_modifier 
	else:
		return GRAVITY * fall_ease

func ease_out(t: float) -> float:
	return sin(t * PI * 0.5)

func wall_slide(delta):
	if is_on_wall() and not is_on_floor():
		## Son Fmod lancement du SFX de grab lorsque la touche est pressée
		## Bug : si le joueur presse Grab en l'air et le maintient pressé lors du contact avec le mur
		## alors le perso va grabber le mur mais le son se jouera pas
		if Input.is_action_just_pressed("Grab"):
			$FmodWallgrab.play()
		if Input.is_action_pressed("Grab"):
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false

	if is_wall_sliding:
		velocity.y += wall_slide_gravity * delta
		velocity.y = min(velocity.y, wall_slide_gravity)


func pause_game():
	pause_instance = pause_menu.instantiate()
	pause_instance.z_index = 100  
	canvas_layer.add_child(pause_instance)  # Ajoute le menu pause au CanvasLayer
	
	# Connecter le signal resume_requested du menu pause à la fonction resume_game
	if pause_instance.has_signal("resume_requested"):
		# Utiliser un Callable pour connecter le signal
		pause_instance.connect("resume_requested", Callable(self, "resume_game"))
	
	$Arm/ReloadTimer.paused = true
	$Arm/Cooldown.paused = true
	get_tree().paused = true

func resume_game():

	if pause_instance != null:

		pause_instance.queue_free()
		pause_instance = null
		get_tree().paused = false
		$Arm/ReloadTimer.paused = false
		$Arm/Cooldown.paused = false
