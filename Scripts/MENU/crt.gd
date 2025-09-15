extends MeshInstance2D

func _ready():
	# Attendre une frame pour s'assurer que tout est initialisé
	await get_tree().process_frame
	
	# Vérifications de sécurité
	var tree = get_tree()
	if not tree or not tree.current_scene:
		return
	
	# Créer l'overlay CRT
	var overlay = CanvasLayer.new()
	overlay.layer = 999  # Très haut dans la hiérarchie
	overlay.name = "CRT_Overlay"
	
	tree.current_scene.add_child(overlay)
	
	# Se déplacer vers l'overlay
	var parent = get_parent()
	if parent:
		parent.remove_child(self)
	overlay.add_child(self)
	
	# Positionner au centre de l'écran
	var screen_size = get_viewport().get_visible_rect().size
	position = screen_size / 2
