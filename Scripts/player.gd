extends CharacterBody2D

# Variables de mouvement du Player
var SPEED = 150
var ACCELERATION = 175.0
var FRICTION = 800.0
var GRAVITY = 1500.0
var JUMP_VELOCITY = -300.0
var BUFFER_PATIENCE = 0.08
var COYOTE_TIME = 0.08
var max_fall_speed : float = 300

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
	print("Camera set to:", camera)

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

	var horizontal_input := Input.get_vector("Move_Left", "Move_Right","Move_Up", "Move_Down")
	var jump_attempted := Input.is_action_just_pressed("Jump")
	print(velocity.length())
	if jump_attempted or input_buffer.time_left > 0:
		if coyote_jump_available and can_jump:
			velocity.y = JUMP_VELOCITY
			Global.shooting_pos = position
			coyote_jump_available = false
		elif jump_attempted:
			input_buffer.start()

	if is_on_floor():
		coyote_jump_available = true
		coyote_timer.stop()
		Global.player_impulsed = false
	else:
		if coyote_jump_available:
			if coyote_timer.is_stopped():
				coyote_timer.start()
		velocity.y += add_gravity() * delta

	var drag_multiplier : float
	if is_on_floor():
		if abs(velocity.x) > SPEED :
			drag_multiplier = 2
		else :
			drag_multiplier = 1
	else : 
		if abs(velocity.x) > SPEED + 100:
			drag_multiplier = 0.5
		else :
			drag_multiplier = 0.2

	
	if not Global.player_impulsed:
		if is_on_floor():
			if abs(horizontal_input.x) >= 0.1:
				if sign(velocity.x) != sign(horizontal_input.x):
					velocity.x = move_toward(velocity.x, 0, FRICTION * delta * drag_multiplier * 10)  #Au sol, fais demi-tour rapidement
				velocity.x = move_toward(velocity.x, sign(horizontal_input.x) * SPEED , ACCELERATION * delta) #Au sol, avance de manière accéléré
			else:
				velocity.x = move_toward(velocity.x, 0, (FRICTION * delta) * drag_multiplier) #Au sol, Friction
		else:
			if abs(horizontal_input.x) >= 0.1:
				if sign(velocity.x) != sign(horizontal_input.x):
					velocity.x = move_toward(velocity.x, 0, FRICTION * delta * drag_multiplier)  #En sautant, fais demi-tour rapidement
				velocity.x = move_toward(velocity.x, sign(horizontal_input.x) * SPEED , ACCELERATION * delta ) #En sautant, avance de manière accéléré 
			else:
				velocity.x = move_toward(velocity.x, 0, (FRICTION * delta) * drag_multiplier) #Au sol, Friction
	else:
		if abs(horizontal_input.x) >= 0.1:
			
			velocity.x = move_toward(velocity.x, sign(horizontal_input.x) * SPEED , ACCELERATION * delta * 2)
		else :
			velocity.x = move_toward(velocity.x, 0, (FRICTION * delta) * drag_multiplier)
	
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
		Global.current_ammo = Global.magazine_size
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
	if Global.player_impulsed :
		var impulsed_modifier = clamp(velocity.length() / 275.0, 0.2, 1.0)
		return GRAVITY * impulsed_modifier
	else:
		var jump_modifier = clamp(abs(velocity.y) / 100.0, 0.15, 1.0)
		return GRAVITY * jump_modifier

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
	print("Resume game function called")
	if pause_instance != null:
		print("Pause instance exists, freeing it")
		pause_instance.queue_free()
		pause_instance = null
		get_tree().paused = false
		$Arm/ReloadTimer.paused = false
		$Arm/Cooldown.paused = false
		input_buffer.paused = false
		coyote_timer.paused = false
