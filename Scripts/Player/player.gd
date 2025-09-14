extends CharacterBody2D

# Variables de mouvement du Player
var SPEED = 150
var ACCELERATION = 250.0
var FRICTION = 800.0
var GRAVITY = 1500.0
var max_fall_speed : float = 250

#Concerne l'interaction avec les murs
var is_grabbing := false
var just_on_wall := false
var was_on_wall := false

var just_landed := false
var was_on_floor := true

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

	wall_sliding(delta)

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

#Permet de descendre des one way plateformes 
	if is_on_floor(): 
		if horizontal_input.y > 0.95:
			position.y += 1

#Concerne l'atterissage au sol
	if is_on_floor() :
		if not was_on_floor :
			just_landed = true
			was_on_floor = true
		else:
			just_landed = false
	else: 
		was_on_floor = false
		just_landed = false

	if just_landed :
		#remplace le son par celui d'atterisage
		$FmodBonk.play()

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

	else: #si le player est en l'air

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

func wall_sliding(delta):
	#Lance un son quand on se tape contre un mur après s'etre propulsé par une rocket
	if is_on_wall() and not is_on_floor():
		if not was_on_wall :
			if Global.player_impulsed :
				##Remplace le son par celui quand on se tape contre un mur
				$FmodBonk.play()
				was_on_wall = true
			was_on_wall = true
		#Detecte si on vient de Grab pour lancer le son associé
		if Input.is_action_pressed("Grab"):
			if not is_grabbing:
				$FmodWallgrab.play()
				is_grabbing = true
		else:
			is_grabbing = false
	else:
		is_grabbing = false
		was_on_wall = false
	#Grab le mur
	if is_grabbing:
		velocity.y = 0


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
