extends Node2D

@onready var crystal_particle: CPUParticles2D = $Crystal_Particle
@onready var timer: Timer = $Timer
@onready var cristal_vrai: Sprite2D = $CristalVrai

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	crystal_particle.emitting = false

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("boom"):
		crystal_particle.emitting = true
		cristal_vrai.visible = false
		timer.start()



func _on_timer_timeout() -> void:
	queue_free()
