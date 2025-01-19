extends Camera2D

# Taille de la "zone de jeu" constante en pixels
@export var target_width : float = 640
@export var target_height : float = 384

func _ready():
	update_zoom()

func _viewport_size_changed():
	# Lorsque la taille de la fenêtre change (passage entre fenêtre et plein écran)
	update_zoom()

# Met à jour le zoom de la caméra en fonction de la taille de la fenêtre
func update_zoom():
	var viewport_size = get_viewport().size
	
	# Calculer le facteur de zoom basé sur la taille de la fenêtre pour que le jeu s'adapte
	var target_aspect = target_width / target_height
	var screen_aspect = viewport_size.x / viewport_size.y
	
	if screen_aspect > target_aspect:
		# Si l'écran est plus large que la zone cible, on ajuste le zoom en fonction de la hauteur
		zoom.y = viewport_size.y / target_height
		zoom.x = zoom.y  # Garder un zoom uniforme
	else:
		# Si l'écran est plus haut ou a le même ratio, on ajuste le zoom en fonction de la largeur
		zoom.x = viewport_size.x / target_width
		zoom.y = zoom.x  # Garder un zoom uniforme
