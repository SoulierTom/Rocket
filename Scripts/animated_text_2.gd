extends Node2D

var animation_finished2 = false

func _ready():
	$Label.visible_ratio = 0.0
	$Area2D.body_entered.connect(_play_animation)

func _play_animation(body):
	print("Body entered: ", body.name)
	# Vérifier que c'est bien le joueur qui entre
	if body.name == "Player" or body.is_in_group("player"):
		$Area2D.body_entered.disconnect(_play_animation)
		$AnimationPlayer.play('Show_Text')
		$FmodTypeScreen2.play()
		$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	if animation_finished2:
		$FmodTypeScreen2.stop()
		animation_finished2 = false
	
func _on_animation_finished(anim_name: StringName):
	print("anim finished")
	animation_finished2 = true
