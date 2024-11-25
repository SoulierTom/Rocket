extends Node2D

# Variables propres au mouvement du bras
var is_using_gamepad = false
var target_pos = Vector2.RIGHT
var last_joystick_vector = Vector2.RIGHT
@export var pos_arm_x = 10.0
@export var pos_arm_y = 10.0


# Permet d'utiliser la Scene Rocket
const RocketScene = preload("res://Scenes/Rocket.tscn")
@onready var shooting_point: Marker2D = $Sprite2D/ShootingPoint


func _ready():
	# Met cet objet en haut de la hiérarchie des rendus (dessiné devant les autres)
	set_as_top_level(true)


func _physics_process(_delta):
	
	# Obtenir la position du personnage (le parent de ce Sprite)
	var character_pos = get_parent().position

	# Attacher le bras à une position relative autour du personnage
	position.x = lerp(position.x, character_pos.x + pos_arm_x, 0.8)
	position.y = lerp(position.y, character_pos.y + pos_arm_y, 0.8)

	var mouse_pos = get_global_mouse_position()
	var joystick_vector = Input.get_vector("Look_Left", "Look_Right", "Look_Up", "Look_Down") 
	
	
	if is_using_gamepad :        
		if joystick_vector.length() > 0.1:
			target_pos = character_pos + joystick_vector * 500
			last_joystick_vector = joystick_vector
			look_at(target_pos)
		else :                     # Quand le joystick est relaché il pointe vers la precedente direction
			target_pos = character_pos + last_joystick_vector * 500
			look_at(target_pos)
	else:                          # La souris bouge, utiliser sa position
			target_pos = mouse_pos
			look_at(target_pos)


func _input(event):
	# Vérifier si l'événement vient d'une manette
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		is_using_gamepad = true  

	# Si une autre entrée (clavier/souris) est détectée, désactiver la manette
	elif event is InputEventMouse or event is InputEventKey:
		is_using_gamepad = false 
	
	if event.is_action_pressed("Shoot"):
		shoot(RocketScene)
		
	
func shoot(projectile: PackedScene) -> void:
	var projectile_instance = projectile.instantiate()
	projectile_instance.position = shooting_point.global_position
	projectile_instance.direction = global_position.direction_to(target_pos)
	add_child(projectile_instance)
