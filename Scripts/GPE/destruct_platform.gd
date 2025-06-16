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
		set_process(true)
		$GPUParticles_normal.emitting = true
		hide_block()
		set_process(false)
		await get_tree().create_timer(1.8).timeout
		$GPUParticles_reverse.emitting = true
		await get_tree().create_timer(1.2).timeout
		show_block()
		
func hide_block():
	$Sprite2D.visible = false
	$CollisionShape2D.disabled = true
	$Area_player/CollisionShape2D.disabled = true
	$Area_rocket/CollisionShape2D.disabled = true

func show_block():
	$Sprite2D.visible = true
	$CollisionShape2D.disabled = false  
	$Area_player/CollisionShape2D.disabled = false
	$Area_rocket/CollisionShape2D.disabled = false
