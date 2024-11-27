extends CharacterBody2D

const SPEED = 240.0
const JUMP_VELOCITY = -350.0

const acc = 13
var friction : int

const grav_up = 10
const grav_down = 35

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var buffer_timer: Timer = $BufferTimer

func _physics_process(delta: float) -> void:
	
	var input_dir: Vector2 = input()
	if input_dir != Vector2.ZERO :
		accelerate(input_dir)
		
	else :
		add_friction()
		
	player_movement()
	jump()
	gravity()
	
	if is_on_floor() :
		friction = 15
		if input_dir == Vector2.ZERO :
			animated_sprite.play("idle")
		else :
			animated_sprite.play("run")
	else : 
		friction = 10
		animated_sprite.play("jump")
		
func jump() :
	
	if Input.is_action_just_pressed("Jump") :
		buffer_timer.start()
	
	if !buffer_timer.is_stopped() and (is_on_floor() || !coyote_timer.is_stopped()) :
		velocity.y = JUMP_VELOCITY
		
	#plus petit saut si le bouton est relaché plus tot
	if Input.is_action_just_released("Jump") :
		if velocity.y < 0.0 :
			velocity.y *= 0.33

func input() -> Vector2:
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("Move_Left","Move_Right")
	if input_dir > Vector2.ZERO :
		animated_sprite.flip_h = false
	elif input_dir < Vector2.ZERO : 
		animated_sprite.flip_h = true
	return input_dir
	
func accelerate(direction):
	velocity = velocity.move_toward(SPEED * direction, acc)
	
func add_friction():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

func player_movement():
	
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	
	if was_on_floor && !is_on_floor() :
		coyote_timer.start()

func gravity():
	if velocity.y < 0 :
		velocity.y += grav_up
	else : 
		velocity.y += grav_down
	
	
	
