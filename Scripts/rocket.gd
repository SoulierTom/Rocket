class_name Projectile
extends CharacterBody2D


@onready var explosion_scene = preload("res://Scenes/Explosion.tscn")

@onready var rocket: Projectile = $"."

@export var speed = 700.0
@export var lifetime = 3.0

var direction = Vector2.ZERO

@onready var existence: Timer = $Existence
@onready var destruction: Timer = $Destruction


func _ready():
	set_as_top_level(true)
	look_at(position + direction)
	
	#désactive le projectile au bout d'un certain temps
	existence.timeout.connect(queue_free)
	

func _physics_process(delta: float) -> void:
	
	
	
	position += direction * speed * delta
	
	
	
	# Déplacement et gestion des collisions
	var collision = move_and_collide(direction * speed * delta)
	
	
	
	if collision:
		
		var explosion_instance = explosion_scene.instantiate()
		explosion_instance.position = global_position
		add_child(explosion_instance)
		
		
		
