class_name Projectile
extends CharacterBody2D

@export var speed = 700.0
@export var lifetime = 3.0

var direction = Vector2.ZERO

@onready var existence: Timer = $Existence


func _ready():
	set_as_top_level(true)
	look_at(position + direction)
	
	#désactive le projectile au bout d'un certain temps
	existence.timeout.connect(queue_free)
	

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	var collision = move_and_collide(direction * delta)
	if collision:
		print("Rocket a touché un mur !")
		queue_free()
	
func _on_body_entered(body):
	print("Collision détectée avec :", body)
	queue_free()
	
	
