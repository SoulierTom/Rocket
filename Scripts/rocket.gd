class_name Projectile
extends Node2D

@export var speed = 1000.0
@export var lifetime = 3.0

var direction = Vector2.ZERO


@onready var rocket: Projectile = $"."
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var impact_detector: Area2D = $ImpactDetector
@onready var existence: Timer = $Existence


func _ready():
	set_as_top_level(true)
	look_at(position + direction)
	
	#désactive le projectile au bout d'un certain temps
	existence.timeout.connect(queue_free)
	
	
	impact_detector.body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	print("Collision détectée avec :", body)
	
	
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
