extends CharacterBody2D

# Variable propre au mouvement du Player
@export var speedGround = 140.0
@export var speedAir = 200.0

@export var jump_height : float = 25
@export var jump_time_to_peak : float = 0.2
@export var jump_time_to_descent : float = 0.15
@export var acceleration_ground = 9
@export var acceleration_air = 9

var friction : int
@onready var buffer_timer: Timer = $BufferTimer
@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = ((-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)) * -1.0
@onready var fall_gravity : float = ((-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent)) * -1.0

@export var max_fall_speed : float = 350.0  # Limite maximale de la vitesse de chute

var recoiling : bool = false
@export var recoil_force : int = 100
@export var recoil_duration : float = 0.025

# Variables propres au bras
@onready var arm = $Arm

# Animations du Player
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_timer: Timer = $CoyoteTimer

func _ready():
	velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	
	# Direction que pointe le bras
	var dir_arm = (Global.target_pos - arm.position).normalized()
	
	# Appliquer la gravité
	velocity.y += calculate_gravity() * delta
	
	# Limiter la vitesse de chute
	if velocity.y > max_fall_speed:
		velocity.y = max_fall_speed

	# Gérer les mouvements horizontaux
	var input_dir: Vector2 = input()
	if input_dir != Vector2.ZERO and is_on_floor():
		accelerate_ground(input_dir)
	elif input_dir != Vector2.ZERO and !is_on_floor():
		accelerate_air(input_dir)
	else:
		add_friction()
	
	jump()
	
	# Détermine qu'elles animations doivent être jouées
	if is_on_floor() :
		friction = 25
		if input_dir == Vector2.ZERO :
			animated_sprite.play("idle")
		else :
			animated_sprite.play("run")
	else : 
		friction = 10
		animated_sprite.play("jump")
		
	# le perso se tourne dans le sens du bras
	if dir_arm.x > 0 :
		animated_sprite.flip_h = false
	if dir_arm.x < 0 :
		animated_sprite.flip_h = true

	#if recoiling:    # easter eggs :))))))))   recoil annulé :((((((
		#velocity += -dir_arm * recoil_force

	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	if was_on_floor && !is_on_floor() :
		coyote_timer.start()

	# Retour au menu principal
	if Input.is_action_just_pressed("exit"):
		get_tree().change_scene_to_file("res://Scenes/Main_Menu.tscn")

func calculate_gravity() -> float:
	# Retourne la gravité appropriée
	return jump_gravity if velocity.y < 0.0 else fall_gravity

func jump() :

	if Input.is_action_just_pressed("Jump") :
		buffer_timer.start()

	if !buffer_timer.is_stopped() and (is_on_floor() || !coyote_timer.is_stopped()) :
		velocity.y = jump_velocity

func input() -> Vector2:
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("Move_Left","Move_Right")
	return input_dir
	
func accelerate_ground(direction):
	velocity = velocity.move_toward(speedGround * direction, acceleration_ground)

func accelerate_air(direction):
	velocity = velocity.move_toward(speedAir * direction, acceleration_air)


func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

func _on_arm_projectile_fired() -> void:
	recoiling = true
	await get_tree().create_timer(recoil_duration).timeout
	recoiling = false
