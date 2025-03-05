extends Sprite2D

@onready var player = $".."
@onready var sprite_2d = $"."
@onready var texture_progress_bar = $"../Arm/RayCast2D/Control/TextureProgressBar"

# Le recul du tir
signal projectile_fired
var recoiling: bool = false
@export var recoil_force: int = 25
var recoil_vector: Vector2 = Vector2.ZERO
@export var recoil_duration: float = 0.025

# Position du bras
@export var pos_arm_x: float = -3.0
@export var pos_arm_y: float = 3.0

# Variables propres au mouvement du bras
var is_using_gamepad = false
var last_joystick_vector = Vector2.RIGHT

func _physics_process(_delta):
	# Orienter le sprite du bras vers la TextureProgressBar
	look_at(texture_progress_bar.global_position)

	# Calculer la direction du bras
	var dir_arm = (texture_progress_bar.global_position - position).normalized()

	# Mise à jour de la position du bras en fonction de la direction
	if dir_arm.x > 0:  # Le bras vise à droite
		z_index = -1  # Devant le personnage
	else:  # Le bras vise à gauche
		z_index = 1  # Derrière le personnage
