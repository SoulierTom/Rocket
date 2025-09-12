@tool

const Util = preload("res://addons/ldtk-importer/src/util/util.gd")

var player_scene = preload("res://Scenes/Player.tscn")  # Précharge la scène Player
var finish_scene = preload("res://Scenes/Next_Level.tscn")  # Précharge la scène Finish
var camera_scene = preload("res://Scenes/camera_limiter.tscn")
var coin_scene = preload("res://Scenes/Coin.tscn")
var crate_scene = preload("res://Scenes/Caisse.tscn")
var breakable_rock_scene = preload("res://Scenes/breakable_rock.tscn")

func post_import(entity_layer: LDTKEntityLayer) -> LDTKEntityLayer:
	var entities: Array = entity_layer.entities  # Stocke une liste d'éléments


	# Script exécuté par chacun des niveaux (depuis le Node "Entities") :
	
	entity_layer.get_node("../Collisions").z_index = 2
	entity_layer.get_node("../Background").z_index = -2
	
	# Création des Color_Rects :
	var color_rect = ColorRect.new()
	entity_layer.add_child(color_rect)
	var size_cr = Vector2(entity_layer.get_node("../Collisions").get_used_rect().size)*8 # définit la taille des colors rects à celle de la tilemap du niveau actuel
	color_rect.name = "Color rec 1"
	color_rect.size = size_cr
	color_rect.color = Color(0, 0, 0, 0.2)
	color_rect.z_index = -1

	var color_rect2 = ColorRect.new()
	entity_layer.add_child(color_rect2)
	color_rect2.name = "Color rec 2"
	color_rect2.size = size_cr
	color_rect2.color = Color(0, 0, 0, 0.2)
	color_rect2.z_index = -3

# Post-process :
	#var canvas = CanvasLayer.new()
	#var color_rect3 = ColorRect.new()
	#var screen_size = Vector2(DisplayServer.window_get_size())
	#entity_layer.add_child(canvas)
	#canvas.add_child(color_rect3)
	#canvas.name = "Canvas_layer"
	#color_rect3.size = screen_size # remplacer la taille de l'écran par la taille du viewport ici !!
	#color_rect3.position = Vector2(-32, -32)
	#color_rect3.name = "ShockwaveShader"
	#color_rect3.color = Color(1, 1, 1, 1)
	#color_rect3.z_index = 2

	#var shockwave = ShaderMaterial.new()
	#shockwave.shader = load("res://Shaders/Shockwave.gdshader")
	#shockwave.set_shader_parameter("radius", 0.0)
	#color_rect3.material = shockwave


# Parallax
	var parallax = Parallax2D.new()
	parallax.name = "Parallax 2D"
	entity_layer.add_child(parallax)
	var background = Sprite2D.new()
	parallax.add_child(background)
	background.texture = load("res://Assets/Graou/Background/Level_1 background-export.png")
	background.name = "Background"
	background.position = (size_cr)/2
	parallax.repeat_size = Vector2(384*3, 0)
	parallax.scroll_scale = Vector2(1.2, 1)
	parallax.repeat_times = 2
	parallax.z_index = -4


# Note à moi-même : Rename tous les nodes parceque les nodes qui commencent avec un @ c'est pas ouf

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
			finish_spawn.name = "Fin du niveau"

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
			camera_limiter.name = "Camera Limiter"

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

		if entity.identifier == "Coin": 

			var coin_spawn = coin_scene.instantiate()
			coin_spawn.position = entity["position"]

			entity_layer.add_child(coin_spawn)

			Util.update_instance_reference(entity.iid, coin_spawn)

			if "Entity_ref" in entity.fields:
				var ref = entity.fields.Entity_ref
				if ref != null:
					coin_spawn.ref = ref
					Util.add_unresolved_reference(coin_spawn, "ref")

		if entity.identifier == "Crate": 

			var crate_spawn = crate_scene.instantiate()
			crate_spawn.position = entity["position"]

			entity_layer.add_child(crate_spawn)

			Util.update_instance_reference(entity.iid, crate_spawn)

			if "Entity_ref" in entity.fields:
				var ref = entity.fields.Entity_ref
				if ref != null:
					crate_spawn.ref = ref
					Util.add_unresolved_reference(crate_spawn, "ref")

		if entity.identifier == "Breakable_Rock": 

			var breakable_rock_spawn = breakable_rock_scene.instantiate()
			breakable_rock_spawn.position = entity["position"]

			entity_layer.add_child(breakable_rock_spawn)

			Util.update_instance_reference(entity.iid, breakable_rock_spawn)

			if "Entity_ref" in entity.fields:
				var ref = entity.fields.Entity_ref
				if ref != null:
					breakable_rock_spawn.ref = ref
					Util.add_unresolved_reference(breakable_rock_spawn, "ref")

	print("Import Réussi")

	return entity_layer
# Be yourself, or die trying.
