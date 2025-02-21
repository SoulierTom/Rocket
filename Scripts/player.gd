extends CharacterBody2D

# Variables de mouvement du Player
@export var SPEED = 200 # Base horizontal movement speed
@export var ACCELERATION = 500.0 # Base acceleration
@export var FRICTION = 800.0 # Base friction
@export var GRAVITY = 2000.0 # Gravity when moving upwards
@export var FALL_GRAVITY = 3000.0 # Gravity when falling downwards
@export var JUMP_VELOCITY = -300.0 # Maximum jump strength
@export var BUFFER_PATIENCE = 0.08 # Input queue patience time
@export var COYOTE_TIME = 0.08 # Coyote patience time

var input_buffer : Timer # Reference to the input queue timer
var coyote_timer : Timer # Reference to the coyote timer
var coyote_jump_available := true

@export var max_fall_speed : float = 350.0  # Limite maximale de la vitesse de chute

@export var min_floating_height : int = 60
@onready var floating_time: Timer = $FloatingTime

# Variables propres au bras
@onready var arm = $Arm

var arm_offset_x: float = 0.85  # Décalage du bras

# Animations du Player
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D


# Référence au menu pause
@onready var pause_menu = preload("res://Scenes/pause_menu.tscn")
var pause_instance = null

func _ready():
	
	# Set up input buffer timer
	input_buffer = Timer.new()
	input_buffer.wait_time = BUFFER_PATIENCE
	input_buffer.one_shot = true
	add_child(input_buffer)

	# Set up coyote timer
	coyote_timer = Timer.new()
	coyote_timer.wait_time = COYOTE_TIME
	coyote_timer.one_shot = true
	add_child(coyote_timer)
	coyote_timer.timeout.connect(coyote_timeout)

func _physics_process(delta: float) -> void:
	
	
	
	# Get inputs
	var horizontal_input := Input.get_axis("Move_Left", "Move_Right")
	var jump_attempted := Input.is_action_just_pressed("Jump")
	
	# Handle jumping
	if jump_attempted or input_buffer.time_left > 0:
		if coyote_jump_available: # If jumping on the ground
			velocity.y = JUMP_VELOCITY
			coyote_jump_available = false
		elif jump_attempted: # Queue input buffer if jump was attempted
			input_buffer.start()

	# Apply gravity and reset coyote jump
	if is_on_floor():
		coyote_jump_available = true
		coyote_timer.stop()
	else:
		if coyote_jump_available:
			if coyote_timer.is_stopped():
				coyote_timer.start()
		velocity.y += add_gravity() * delta

	if horizontal_input != 0:
		cancel_floating()
	if is_floating:
		velocity.y = 0
	# Handle horizontal motion and friction
	var floor_damping := 1.0 if is_on_floor() else 0.2 # Set floor damping, friction is less when in air
	if horizontal_input:
		if sign(velocity.x) != horizontal_input : # If you move at the opposite direction of your current movement, you will stop your movement quik.
			velocity.x = move_toward(velocity.x, 0, FRICTION * delta * floor_damping * 2)
		velocity.x = move_toward(velocity.x, horizontal_input * SPEED, ACCELERATION * delta)
	elif is_floating :
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, (FRICTION * delta) * floor_damping)
	
	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed
	
	# Apply velocity
	move_and_slide()
	
	# Direction que pointe le bras
	var dir_arm = (Global.target_pos - arm.global_position).normalized()
	
	# Détermine quelles animations doivent être jouées
	if is_on_floor():
		if horizontal_input == 0:
			# Animation "idle" ou "idle_left" selon la direction du bras
			if dir_arm.x > 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("idle_left")
		else:
			# Animation "run" ou "run_left" selon la direction du bras
			if dir_arm.x > 0:
				animated_sprite.play("run")
			else:
				animated_sprite.play("run_left")
	else:
		# Animation "jump" ou "jump_left" selon la direction du bras
		if dir_arm.x > 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("jump_left")

	# Gestion du menu pause
	if Input.is_action_just_pressed("ui_cancel"):
		if pause_instance == null:
			pause_game()
		else:
			resume_game()
	
	if is_on_floor():
		Global.player_impulsed = false
	
var is_floating := false
var was_going_up := false  # Permet de suivre le changement de direction


func add_gravity() -> float:
	# Si on monte, garder une trace
	if velocity.y < 0:
		was_going_up = true
		return GRAVITY
		
	# Détection du sommet : la vitesse était négative et devient positive
	if was_going_up and velocity.y > 0 and Global.player_impulsed and not is_floating:
		was_going_up = false  # Réinitialiser
		var delta_height =  Global.shooting_pos.y - position.y # Distance verticale parcourue
		print(delta_height)
		if delta_height > min_floating_height:  # Vérifier si la hauteur atteinte est suffisante
			is_floating = true
			velocity.y = 0  # ❗Bloquer la vitesse verticale pour éviter toute descente
			floating_time.start()
	if is_floating:
		velocity.y = 0  # ❗Bloquer la vitesse verticale pour éviter toute descente
		return 0.0

	# Pendant la phase de flottement, la gravité est désactivée
	

 # Appliquer la gravité de chute normale
	return FALL_GRAVITY



func cancel_floating():
	if floating_time:  # Si un timer est en cours, on l'annule
		floating_time.stop()
		is_floating = false  # Désactiver le flottement
		print("Flottement annulé par un nouveau tir")


## Reset coyote jump
func coyote_timeout() -> void:
	coyote_jump_available = false



func pause_game():
	print("Pausing game")
	pause_instance = pause_menu.instantiate()
	pause_instance.z_index = 100  
	add_child(pause_instance)

	# Mettre en pause tous les Timers
	$Arm/ReloadTimer.paused = true
	$Arm/Cooldown.paused = true
	input_buffer.paused = true
	coyote_timer.paused = true

	get_tree().paused = true

func resume_game():
	if pause_instance != null:
		pause_instance.queue_free()
		pause_instance = null

		# Enlever la pause globale
		get_tree().paused = false

		# Reprendre tous les Timers
		$Arm/ReloadTimer.paused = false
		$Arm/Cooldown.paused = false
		input_buffer.paused = false
		coyote_timer.paused = false


func _on_floating_time_timeout() -> void:
	is_floating = false  # Désactiver le flottement après le timeout
	
