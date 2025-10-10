extends Node

# Le point que regarde le bras (soit la souris, soit le joystick)
var target_pos = Vector2.LEFT


@export var magazine_size: int = 4  # Taille du chargeur (ex: 3 rockets)
var current_ammo: int = magazine_size  # Rockets restantes

var speedrun_time = 0
var timer_initialized = false  # Ajoutez cette variable pour contrôler l'initialisation

var player_impulsed : bool = false
var shooting_pos : Vector2 
var is_floating : bool = false


var VBR = true

var current_level_crystals : int = 0
var total_crystal : int = 0
