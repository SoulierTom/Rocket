class_name Projectile
extends Node2D

@export var speed = 1000.0
@export var lifetime = 3.0

var direction = Vector2.ZERO

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var impact_detector: Area2D = $ImpactDetector
@onready var existence: Timer = $Existence


func _ready():
	set_as_top_level(true)
	look_at(position + direction)

	#timer.connect("timeout", self, "queue_free")
	#timer.start(lifetime)

	#impact_detector.connect("body_entered", self, "_on_impact")

func _physics_process(_delta: float) -> void:
	position += direction * speed * _delta

func _on_impact(body: Node) -> void:
	queue_free()
