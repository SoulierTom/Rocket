extends Node2D

var animation_finished2 = false
@export var AnimatedTuto: AnimatedSprite2D
@export var TextTuto: Label

func _ready():
	$Label.visible_ratio = 0.0
	$Area2D.body_entered.connect(_play_animation)
	if AnimatedTuto:
		AnimatedTuto.visible = false
	if TextTuto:
		TextTuto.visible = false

func _play_animation(body):
	print("Body entered: ", body.name)
	# Vérifier que c'est bien le joueur qui entre
	if body.name == "Player" or body.is_in_group("player"):
		$Area2D.body_entered.disconnect(_play_animation)
		$AnimationPlayer.play('Show_Text')
		
		AnimatedTuto.modulate.a = 0.0  # Commencer invisible
		AnimatedTuto.visible = true
		var tween1 = create_tween()
		tween1.set_trans(Tween.TRANS_CUBIC)  # Type de transition
		tween1.set_ease(Tween.EASE_IN)      # Type d'accélération
		tween1.tween_property(AnimatedTuto, "modulate:a", 1.0, 2.0)
		
		TextTuto.modulate.a = 0.0  
		TextTuto.visible = true
		var tween2 = create_tween()
		tween2.set_trans(Tween.TRANS_CUBIC)  # Type de transition
		tween2.set_ease(Tween.EASE_IN)      # Type d'accélération
		tween2.tween_property(TextTuto, "modulate:a", 1.0, 2.0) 
		
		$FmodTypeScreen2.play()
		$AnimationPlayer.animation_finished.connect(_on_animation_finished)

func _process(delta: float) -> void:
	if animation_finished2:
		$FmodTypeScreen2.stop()
		animation_finished2 = false
	
func _on_animation_finished(anim_name: StringName):
	print("anim finished")
	animation_finished2 = true
