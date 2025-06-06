extends CharacterBody2D

# Variables de mouvement du Player
var SPEED = 150
var ACCELERATION = 250.0
var FRICTION = 800.0
var GRAVITY = 1500.0
var JUMP_VELOCITY = -300.0
var BUFFER_PATIENCE = 0.08
var COYOTE_TIME = 0.08
var max_fall_speed : float = 300

var is_wall_sliding = false
const wall_slide_gravity = 30

var input_buffer : Timer
var coyote_timer : Timer
var coyote_jump_available := true

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

var can_jump := true

# Ajoutez une référence au CanvasLayer
@onready var canvas_layer = $CanvasLayer

# Méthode pour définir la caméra
func set_camera(new_camera: Camera2D):
	camera = new_camera
	camera.make_current()  # Active cette caméra (Godot 4)


func _ready():
	input_buffer = Timer.new()
	input_buffer.wait_time = BUFFER_PATIENCE
	input_buffer.one_shot = true
	add_child(input_buffer)

	coyote_timer = Timer.new()
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.one_shot = true
	add_child(coyote_timer)
	coyote_timer.timeout.connect(coyote_timeout)

func _physics_process(delta: float) -> void:

	
	if Input.is_action_just_pressed("reset"):
		get_tree().change_scene_to_file("res://Levels/From_LDtk/levels/Level_0.scn")
		Global.speedrun_time = 0
	# Toggle des vibrations
	if Input.is_action_just_pressed("toggle_vibration"):
		Global.VBR = !Global.VBR

		
	var horizontal_input := Input.get_vector("Move_Left", "Move_Right","Move_Up", "Move_Down")
	
	
	if is_on_floor():
		Global.player_impulsed = false
	else:
		velocity.y += add_gravity() * delta

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
				velocity.x = move_toward(velocity.x, 0, (FRICTION * delta) * 0.5) #en l'air, Friction
	else:
		if abs(horizontal_input.x) >= 0.1:
			if sign(velocity.x) != sign(horizontal_input.x):
					velocity.x = move_toward(velocity.x, 0, FRICTION * delta * 0.1) #Propulsé
			velocity.x = move_toward(velocity.x, sign(horizontal_input.x) * SPEED, ACCELERATION * delta * 1)
		else :
			velocity.x = move_toward(velocity.x, 0, (FRICTION * delta) * 0.1)
	
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
					$walk_sound.play()
				if current_frame >= 2 and current_frame < 3:
					$walk_sound.play()
			else:
				animated_sprite.play("run_left")
				if current_frame >= 0 and current_frame < 1:
					$walk_sound.play()
					
				if current_frame >= 2 and current_frame < 3:
					$walk_sound.play()
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

	if is_on_floor():
			reload()

func add_gravity() -> float:
	if Global.player_impulsed :
		var impulsed_modifier = clamp(velocity.length() / 275.0, 0.2, 1.0)
		return GRAVITY * impulsed_modifier
	
	else:
		var jump_modifier = clamp(abs(velocity.y) / 100.0, 0.15, 1.0)
		return GRAVITY * jump_modifier

func wall_slide(delta):
	if is_on_wall() and not is_on_floor():
		if Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_right"):
			is_wall_sliding = true
		else:
			is_wall_sliding = false
	else:
		is_wall_sliding = false

	if is_wall_sliding:
		velocity.y += wall_slide_gravity * delta
		velocity.y = min(velocity.y, wall_slide_gravity)

func coyote_timeout() -> void:
	coyote_jump_available = false

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
	input_buffer.paused = true
	coyote_timer.paused = true
	get_tree().paused = true

func resume_game():

	if pause_instance != null:

		pause_instance.queue_free()
		pause_instance = null
		get_tree().paused = false
		$Arm/ReloadTimer.paused = false
		$Arm/Cooldown.paused = false
		input_buffer.paused = false
		coyote_timer.paused = false

func reload():
	Global.current_ammo = Global.magazine_size
