extends Line2D

class_name CameraBounds

# Propriétés exportées pour l'éditeur
@export var bounds_color: Color = Color.RED
@export var bounds_width: float = 2.0
@export var visible_in_game: bool = false  # Masquer en jeu par défaut

# Signal émis quand les limites changent
signal bounds_changed

func _ready():
	# Configuration visuelle
	default_color = bounds_color
	width = bounds_width
	
	# Masquer en jeu si nécessaire
	if not visible_in_game and not Engine.is_editor_hint():
		visible = false
	
	# Connecter les changements de points
	connect("visibility_changed", _on_visibility_changed)

func _on_visibility_changed():
	emit_signal("bounds_changed")

# Fonction pour ajouter un point aux limites
func add_boundary_point(pos: Vector2):
	add_point(pos)
	emit_signal("bounds_changed")

# Fonction pour effacer tous les points
func clear_boundaries():
	clear_points()
	emit_signal("bounds_changed")

# Fonction pour obtenir le rectangle englobant des limites
func get_bounds_rect() -> Rect2:
	if get_point_count() < 2:
		return Rect2()
	
	var min_pos = points[0]
	var max_pos = points[0]
	
	for i in range(1, get_point_count()):
		var point = points[i]
		min_pos.x = min(min_pos.x, point.x)
		min_pos.y = min(min_pos.y, point.y)
		max_pos.x = max(max_pos.x, point.x)
		max_pos.y = max(max_pos.y, point.y)
	
	return Rect2(min_pos, max_pos - min_pos)

# Fonction pour vérifier si un point est dans les limites
func is_point_within_bounds(point: Vector2) -> bool:
	var bounds = get_bounds_rect()
	return bounds.has_point(point)

# Fonction pour contraindre un point dans les limites
func constrain_point_to_bounds(point: Vector2) -> Vector2:
	var bounds = get_bounds_rect()
	if bounds.size == Vector2.ZERO:
		return point
	
	var constrained = point
	constrained.x = clamp(constrained.x, bounds.position.x, bounds.position.x + bounds.size.x)
	constrained.y = clamp(constrained.y, bounds.position.y, bounds.position.y + bounds.size.y)
	
	return constrained

# Fonction pour définir des limites rectangulaires simples
func set_rectangular_bounds(top_left: Vector2, bottom_right: Vector2):
	clear_points()
	add_point(top_left)
	add_point(Vector2(bottom_right.x, top_left.y))  # Top right
	add_point(bottom_right)  # Bottom right
	add_point(Vector2(top_left.x, bottom_right.y))  # Bottom left
	add_point(top_left)  # Fermer le rectangle
	emit_signal("bounds_changed")

# Fonction pour définir des limites à partir d'un Rect2
func set_bounds_from_rect(rect: Rect2):
	set_rectangular_bounds(rect.position, rect.position + rect.size)
