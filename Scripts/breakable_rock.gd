extends StaticBody2D

var time := 1.0

func _ready():
	set_process(false)

func _process(_delta):
	time += 0.075
	$Sprite2D.position += Vector2(0, sin(time) * 0.5)

func _on_area_2d_body_entered(body):
	if body.name == 'Player':
		set_process(true)
		$Timer.start(1.0)
	
func _on_area_rocket_area_entered(area: Area2D):
	if area.is_in_group("destruction"):
			print("exploded")
			set_process(true)
			$Timer.start(0.1)  # Destruction plus rapide par l'explosion


func _on_timer_timeout():
	if is_processing():
		set_process(false)
		$GPUParticles2D.emitting = true
		$Area_player.queue_free()
		$Area_rocket.queue_free()
		$CollisionShape2D.queue_free()
		$Sprite2D.queue_free()
		$Timer.start(1.2)
	else:
		queue_free()
