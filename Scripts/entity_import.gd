extends Node

# Preload entity scenes (adjust paths accordingly)
const ENTITY_SCENES = {
	"Finish": preload("res://scenes/Finish.tscn"),
	"PlayerStart": preload("res://scenes/PlayerStart.tscn")
}

# Function to load JSON and spawn entities
func load_level_entities(json_path: String, level_node: Node):
	var file = FileAccess.open(json_path, FileAccess.READ)
	if file == null:
		print("Failed to open JSON file:", json_path)
		return
	
	var json_data = JSON.parse_string(file.get_as_text())
	if json_data == null:
		print("Invalid JSON format!")
		return
	
	# Process entity placement
	if json_data.has("entities"):
		for entity_id in json_data["entities"]:
			if ENTITY_SCENES.has(entity_id):
				for entity_data in json_data["entities"][entity_id]:
					spawn_entity(entity_id, entity_data, level_node)

# Function to spawn an entity
func spawn_entity(entity_id: String, entity_data: Dictionary, parent: Node):
	var entity_scene = ENTITY_SCENES[entity_id]
	if entity_scene == null:
		print("Scene not found for entity:", entity_id)
		return
	
	var entity_instance = entity_scene.instantiate()
	entity_instance.position = Vector2(entity_data["x"], entity_data["y"])
	parent.add_child(entity_instance)

	print("Spawned", entity_id, "at", entity_instance.position)
