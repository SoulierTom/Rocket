extends Camera2D

# Taille de la "zone de jeu" constante en pixels -> doit être en 16:10
@export var target_width: float = 640
@export var target_height: float = 384

func _ready():
	update_zoom()

func _viewport_size_changed():
	# Lors du redimensionnement de la fenêtre
	update_zoom()

# Met à jour le zoom pour s'adapter à la taille de la fenêtre
func update_zoom():
	var viewport_size = get_viewport().size
	
	# Calculer le facteur de zoom basé sur la taille de la fenêtre pour que le jeu s'adapte
	var target_aspect = target_width / target_height
	var screen_aspect = viewport_size.x / viewport_size.y
	
	if screen_aspect > target_aspect:
		# Ajuste le zoom selon la hauteur
		zoom.y = viewport_size.y / target_height
		zoom.x = zoom.y
	else:
		# Ajuste le zoom selon la largeur
		zoom.x = viewport_size.x / target_width
		zoom.y = zoom.x
