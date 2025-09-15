extends Node2D

func _ready():
	$Label.visible_ratio = 0.0
	$Area2D.body_entered.connect(_play_animation)

func _play_animation(body):
	print("Body entered: ", body.name)
	# Vérifier que c'est bien le joueur qui entre
	if body.name == "Player" or body.is_in_group("player"):
		$Area2D.body_entered.disconnect(_play_animation)
		$AnimationPlayer.play('Show_Text')
