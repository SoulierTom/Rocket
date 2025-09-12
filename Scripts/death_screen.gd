extends CanvasLayer

signal on_death_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

func _ready():
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished(anim_name):
		if anim_name == "fade_to_black":
			on_death_finished.emit()
			#Fmod Son : lancement de l'Event Respawn en direct sans passer par un Emitter Node
			FmodServer.play_one_shot("event:/UI-and-Events/Respawn")
			animation_player.play("fade_to_normal")
		elif anim_name == "fade_to_normal":
			color_rect.visible = false

func death():
	color_rect.visible = true
	animation_player.play("fade_to_black")
	#Fmod Son : lancement de l'Event Death en direct sans passer par un Emitter Node
	FmodServer.play_one_shot("event:/UI-and-Events/Death")
