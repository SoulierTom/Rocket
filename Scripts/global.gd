extends Node

#le point que regarde le bras (soit la souris, soit le joystick)
var target_pos = Vector2.RIGHT

@export var magazine_size: int = 3 # Taille du chargeur (ex: 3 rockets)
var current_ammo: int = magazine_size # Rockets restantes

var speedrun_time = 0
