extends Node2D

@onready var player = $".."

# Variables propres au mouvement du bras
var is_using_gamepad = false
var last_joystick_vector = Vector2(0.5,0.866)

# Position du bras
@export var pos_arm_x: float = -3
@export var pos_arm_y: float = 2

@export var arm_position_right: Vector2 = Vector2(2, 3)
@export var arm_position_left: Vector2 = Vector2(-2, 3)


# Le recul du tir
signal projectile_fired
var recoiling: bool = false
@export var recoil_force: int = 25
var recoil_vector: Vector2 = Vector2.ZERO
@export var recoil_duration: float = 0.025


@onready var cooldown: Timer = $Cooldown # Cooldown entre 2 tirs


# Permet d'utiliser la Scene Rocket
const RocketScene = preload("res://Scenes/Rocket.tscn")
@onready var shooting_point: Marker2D = $Sprite2D/ShootingPoint

# Permet de générer l'explosion
@export var explosion_scene: PackedScene

func _ready():
	set_as_top_level(true)  # Dessine l'objet devant les autres
	$RayCast2D.z_index = 10

func _physics_process(_delta):
	var character_pos = get_parent().position
	var dir_arm = (Global.target_pos - position).normalized()
	recoil_vector = -dir_arm * recoil_force
	position.x = lerp(position.x, character_pos.x + pos_arm_x, 0.85)
	position.y = lerp(position.y, character_pos.y + pos_arm_y, 0.85)

	if recoiling:
		position.x = lerp(position.x, character_pos.x + pos_arm_x + recoil_vector.x, 0.8)
		position.y = lerp(position.y, character_pos.y + pos_arm_y + recoil_vector.y, 0.8)

	var mouse_pos = get_global_mouse_position()
	var joystick_vector = Input.get_vector("Look_Left", "Look_Right", "Look_Up", "Look_Down")

	if is_using_gamepad:
		if joystick_vector.length() > 0.1:
			Global.target_pos = character_pos + joystick_vector * 1000000
			last_joystick_vector = joystick_vector
			look_at(Global.target_pos)
		else:
			Global.target_pos = character_pos + last_joystick_vector * 1000000
			look_at(Global.target_pos)
	else:
		Global.target_pos = mouse_pos
		look_at(Global.target_pos)
	
	$RayCast2D.update_ammo_display()
	
	if dir_arm.x > 0:  # Le bras vise à droite
		z_index = 1  # Devant le personnage
	else:  # Le bras vise à gauche
		z_index = -1  # Derrière le personnage
	
func _input(event):
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		is_using_gamepad = true
	elif event is InputEventMouse or event is InputEventKey:
		is_using_gamepad = false

	if event.is_action_pressed("Shoot") and cooldown.is_stopped():
		if Global.current_ammo > 0:
			shoot(RocketScene)
			projectile_fired.emit()
			Global.current_ammo -= 1
			$RayCast2D.update_ammo_display()

			recoiling = true
			await get_tree().create_timer(recoil_duration).timeout
			recoiling = false
		#else: #Insérer ici le feedback qui indique que le chargeur est vide


func shoot(projectile: PackedScene) -> void:
	var projectile_instance = projectile.instantiate()
	projectile_instance.position = player.global_position
	projectile_instance.direction = global_position.direction_to(Global.target_pos)
	add_child(projectile_instance)
	$Tir.play()
	Global.shooting_pos = player.position
	cooldown.start()


func create_explosion(explosion_position: Vector2) -> void:
	if explosion_scene:
		var explosion_instance = explosion_scene.instantiate()
		explosion_instance.global_position = explosion_position
		add_child(explosion_instance)
		$Explosion.play()
