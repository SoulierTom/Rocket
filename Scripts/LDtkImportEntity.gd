@tool

const Util = preload("res://addons/ldtk-importer/src/util/util.gd")

var player_scene = preload("res://Scenes/Player.tscn")  # Préchargez la scène Player
var finish_scene = preload("res://Scenes/Next_Level.tscn")  # Préchargez la scène Arrivée
var camera_scene = preload("res://Scenes/camera_limiter.tscn")


func post_import(entity_layer: LDTKEntityLayer) -> LDTKEntityLayer:
	var entities: Array = entity_layer.entities  # Stocke une liste d'éléments


	# Script exécuté par chacun des niveaux (depuis le Node "Entities") :
	
	entity_layer.get_node("../Collisions").z_index = 2
	entity_layer.get_node("../Background").z_index = -2
	
	# Création des Color_Rects :
	var color_rect = ColorRect.new()
	entity_layer.add_child(color_rect)
	var size_cr = Vector2(entity_layer.get_node("../Collisions").get_used_rect().size)*8 # définit la taille des colors rects à celle de la tilemap du niveau actuel
	color_rect.size = size_cr
	color_rect.color = Color(0, 0, 0, 0.2)
	color_rect.z_index = -1

	var color_rect2 = ColorRect.new()
	entity_layer.add_child(color_rect2)
	color_rect2.size = size_cr
	color_rect2.color = Color(0, 0, 0, 0.2)
	color_rect2.z_index = -3


	for entity in entities: # C'est ici que les entitées vont être créés en fonction de leurs noms
		
		if entity.identifier == "PlayerStart": 

			# Instancie le Joueur
			var player_spawn = player_scene.instantiate()
			player_spawn.position = entity["position"]  # Positionne le joueur

			# Ajoute le node Player à la scène
			entity_layer.add_child(player_spawn)

			# Met à jour les références (me demandez pas c'est quoi une référence)
			Util.update_instance_reference(entity.iid, player_spawn)

			if "Entity_ref" in entity.fields:
				var ref = entity.fields.Entity_ref
				if ref != null:
					player_spawn.ref = ref
					Util.add_unresolved_reference(player_spawn, "ref")
		
		if entity.identifier == "Finish":  

			var finish_spawn = finish_scene.instantiate()
			finish_spawn.position = entity["position"]
			finish_spawn.next_level_number =entity["fields"]["Next_Level"]

			entity_layer.add_child(finish_spawn)

			Util.update_instance_reference(entity.iid, finish_spawn)

			if "Entity_ref" in entity.fields:
				var ref = entity.fields.Entity_ref
				if ref != null:
					finish_spawn.ref = ref
					Util.add_unresolved_reference(finish_spawn, "ref")

		if entity.identifier == "Camera_Limiter":

			var camera_limiter = camera_scene.instantiate()
			camera_limiter.position = entity["position"]
			camera_limiter.limit_x = entity["fields"]["BorderX"]
			camera_limiter.limit_y = entity["fields"]["BorderY"]

			entity_layer.add_child(camera_limiter)
			
			# Setup des caméra limiters :
			var new_node = Node2D.new()
			new_node.name = "LimitPosition" 
			camera_limiter.add_child(new_node)
			new_node.global_position = (entity["fields"]["Camera_Border"] * 8)

			Util.update_instance_reference(entity.iid, camera_limiter)
			
			# Modifier la position des enfants de Camera_Limiter
			#var limit_position = camera_limiter.get_node("LimitPosition")  # Accédez à LimitPosition

			# Définit la position des enfants
			#limit_position.position = entities["Camera_Border"]  # Déplace LimitPosition de 20 pixels vers le bas
			
			if "Entity_ref" in entity.fields:
				var ref = entity.fields.Entity_ref
				if ref != null:
					camera_limiter.ref = ref
					Util.add_unresolved_reference(camera_limiter, "ref")

	print("Import Réussi")

	return entity_layer
