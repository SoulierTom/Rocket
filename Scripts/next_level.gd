extends Area2D

const FILE_BEGIN = "res://Levels/From_Godot/Test_Level_" 
#const FILE_BEGIN = "res://Levels/From_LDtk/levels/Level_" ->  Script pour niveau LDTK

@export var next_level_number = 0

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var current_scene_file = get_tree().current_scene.scene_file_path
		var next_level_number = current_scene_file.to_int() + 1
		#var next_level_number = int(next_level_number) ->  Script pour niveau LDTK
		
		var next_level_path = FILE_BEGIN + str(next_level_number) + ".tscn"
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file(next_level_path)
