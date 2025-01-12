extends CharacterBody2D

# Variable propre au movment du Player
@export var SPEED = 240.0
@export var JUMP_VELOCITY = -350.0
@export var acceleration = 13
var friction : int
@onready var buffer_timer: Timer = $BufferTimer


var recoiling : bool = false
@export var recoil_force : int = 100
@export var recoil_duration : float = 0.025

# Gravité
const grav_up = 10
const grav_down = 35

# Variables propres au bras
@onready var arm = $Arm
var dir_arm : Vector2   

# Animations du Player
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_timer: Timer = $CoyoteTimer

func _physics_process(delta: float) -> void:
	# Direction que pointe le bras
	var dir_arm = (Global.target_pos - arm.position).normalized()
	
	var input_dir: Vector2 = input()
	if input_dir != Vector2.ZERO :   # Déplace le Player si les inputs directionnels sont utilisés
		accelerate(input_dir)
	else :                           # Sinon le Player subit de la Friction
		add_friction()
	
	jump()
	gravity()
	
	# Détermine qu'elles animations doivent etre jouées
	if is_on_floor() :
		friction = 15
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

	if recoiling:    # Repousse le PLayer dans le sens opposé de la direction de son bras
		velocity += -dir_arm * recoil_force

	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	if was_on_floor && !is_on_floor() :
		coyote_timer.start()

func jump() :

	if Input.is_action_just_pressed("Jump") :
		buffer_timer.start()

	if !buffer_timer.is_stopped() and (is_on_floor() || !coyote_timer.is_stopped()) :
		velocity.y = JUMP_VELOCITY

func input() -> Vector2:
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("Move_Left","Move_Right")
	return input_dir
	
func accelerate(direction):
	velocity = velocity.move_toward(SPEED * direction, acceleration)
	
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

func gravity():
	if velocity.y < 0 :
		velocity.y += grav_up
	else : 
		velocity.y += grav_down

func _on_arm_projectile_fired() -> void:
	recoiling = true
	await get_tree().create_timer(recoil_duration).timeout
	recoiling = false
