extends Area2D

# const FILE_BEGIN = "res://Scenes/Test_Level_" -> Old Script
const FILE_BEGIN = "res://Levels/From_LDtk/levels/Level_"
@export var next_level_number = 0

func _on_body_entered(body):
	if body.is_in_group("Player"):
		# var current_scene_file = get_tree().current_scene.scene_file_path
		#var next_level_number = current_scene_file.to_int() + 1 -> Old Script
		var next_level_number = int(next_level_number)
		
		var next_level_path = FILE_BEGIN + str(next_level_number) + ".scn"
		TransitionScreen.transition()
		await TransitionScreen.on_transition_finished
		get_tree().change_scene_to_file(next_level_path)
