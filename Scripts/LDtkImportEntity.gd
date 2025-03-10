@tool

const Util = preload("res://addons/ldtk-importer/src/util/util.gd")

var player_scene = preload("res://Scenes/Player.tscn")  # Préchargez la scène Player
var finish_scene = preload("res://Scenes/Next_Level.tscn")  # Préchargez la scène Arrivée
var camera_scene = preload("res://Scenes/camera_limiter.tscn")


func post_import(entity_layer: LDTKEntityLayer) -> LDTKEntityLayer:
	var entities: Array = entity_layer.entities  # Stocke une liste d'éléments

	for entity in entities:
		
		# Vérifiez que l'entité est bien celle que vous souhaitez traiter
		if entity.identifier == "PlayerStart":  # Remplacez par l'identifiant de votre entité

			# Instanciez le nœud Player
			var player_spawn = player_scene.instantiate()
			player_spawn.position = entity["position"]  # Positionnez le joueur

			# Ajoutez le nœud Player à la scène
			entity_layer.add_child(player_spawn)

			# Mettez à jour les références
			Util.update_instance_reference(entity.iid, player_spawn)

			# Gérez les références supplémentaires si nécessaire
			if "Entity_ref" in entity.fields:
				var ref = entity.fields.Entity_ref
				if ref != null:
					player_spawn.ref = ref
					Util.add_unresolved_reference(player_spawn, "ref")
		
		if entity.identifier == "Finish":  

			var finish_spawn = finish_scene.instantiate()
			finish_spawn.position = entity["position"]

			entity_layer.add_child(finish_spawn)

			Util.update_instance_reference(entity.iid, finish_spawn)

			if "Entity_ref" in entity.fields:
				var ref = entity.fields.Entity_ref
				if ref != null:
					finish_spawn.ref = ref
					Util.add_unresolved_reference(finish_spawn, "ref")

		if entity.identifier == "Camera_Limiter":  # Remplacez par l'identifiant de votre entité

			# Instanciez le nœud Camera_Limiter
			var camera_limiter = camera_scene.instantiate()
			camera_limiter.position = entity["position"]  # Positionnez Camera_Limiter

			# Ajoutez Camera_Limiter à la scène
			entity_layer.add_child(camera_limiter)

			# Mettez à jour les références
			Util.update_instance_reference(entity.iid, camera_limiter)
			
			# Modifiez la position des enfants de Camera_Limiter
			#var limit_position = camera_limiter.get_node("LimitPosition")  # Accédez à LimitPosition

			# Définissez la position des enfants
			#limit_position.position = entities["Camera_Border"]  # Déplacez LimitPosition de 20 pixels vers le bas
			
			if "Entity_ref" in entity.fields:
				var ref = entity.fields.Entity_ref
				if ref != null:
					camera_limiter.ref = ref
					Util.add_unresolved_reference(camera_limiter, "ref")


	return entity_layer
