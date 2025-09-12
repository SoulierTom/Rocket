extends RayCast2D

# Références UI
@onready var ammo_ui: Control = $Control
@onready var carre1: ColorRect = $"Carré1"
@onready var carre2: ColorRect = $"Carré2"
@onready var carre3: ColorRect = $"Carré3"

# Références aux angles du curseur
@onready var cursor_middle: Node2D = $Control/CursorMiddle
@onready var cursor_angles: Array[Node2D] = [
	$Control/CursorAngle,
	$Control/CursorAngle2,
	$Control/CursorAngle3,
	$Control/CursorAngle4
]

# Configuration
@export_group("Viseur")
@export var pos_viseur_x: float = 0
@export var pos_viseur_y: float = 0
@export var crosshair_shader: ShaderMaterial

@export_group("Recul")
@export var recoil_distance: float = 20.0
@export var recoil_duration: float = 0.2
@export var return_duration: float = 0.3

@export_group("Précision")
@export var spread_curve: Curve
@export var max_spread_distance: float = 30.0
@export var spread_recovery_speed: float = 2.0

# Variables internes
var original_positions: Array[Vector2] = []
var last_ammo_count: int = 0
var current_spread_time: float = 0.0
var angle_materials: Array[ShaderMaterial] = []

# Directions pour chaque angle (diagonales) - initialisées dans _ready
var angle_directions: Array[Vector2] = []

func _ready():
	# Initialise les directions des angles
	angle_directions = [
		Vector2(-1, -1).normalized(),  # Haut-gauche
		Vector2(1, -1).normalized(),   # Haut-droite
		Vector2(1, 1).normalized(),    # Bas-droite
		Vector2(-1, 1).normalized()    # Bas-gauche
	]
	
	setup_crosshair()
	initialize_spread_curve()
	setup_shaders()
	update_ammo_display()
	
	# Configuration du viseur
	z_index = 10
	last_ammo_count = Global.current_ammo

func _process(delta):
	update_position()
	handle_shooting_detection()
	update_spread(delta)
	update_ui_rotation()
	update_ammo_display()
	look_at(Global.target_pos)

# === CONFIGURATION INITIALE ===

func setup_crosshair():
	"""Configure les positions initiales des angles"""
	original_positions.clear()
	
	for i in range(cursor_angles.size()):
		if cursor_angles[i]:
			original_positions.append(cursor_angles[i].position)
		else:
			original_positions.append(Vector2.ZERO)
			push_warning("Angle cursor %d non trouvé" % (i + 1))

func initialize_spread_curve():
	"""Crée une courbe par défaut si nécessaire"""
	if not spread_curve:
		spread_curve = Curve.new()
		spread_curve.add_point(Vector2(0.0, 0.0))  # Début : pas de spread
		spread_curve.add_point(Vector2(0.1, 1.0))  # Pic rapide
		spread_curve.add_point(Vector2(1.0, 0.0))  # Retour à 0 après 1 seconde

func setup_shaders():
	"""Récupère les shaders déjà attachés manuellement"""
	angle_materials.clear()
	
	for i in range(cursor_angles.size()):
		if cursor_angles[i]:
			var renderable = find_renderable_node(cursor_angles[i])
			if renderable and renderable.material and renderable.material is ShaderMaterial:
				var existing_material = renderable.material as ShaderMaterial
				# Configure les paramètres initiaux pour 4 roquettes
				existing_material.set_shader_parameter("angle_id", i + 1)
				existing_material.set_shader_parameter("current_ammo", Global.current_ammo)
				# Assure-toi que le shader supporte jusqu'à 4 munitions
				angle_materials.append(existing_material)
			else:
				angle_materials.append(null)
		else:
			angle_materials.append(null)

# === GESTION DE LA POSITION ET DU MOUVEMENT ===

func update_position():
	"""Met à jour la position du viseur"""
	position.x = pos_viseur_x
	position.y = pos_viseur_y

func update_ui_rotation():
	"""Maintient l'UI face à l'écran"""
	if not ammo_ui:
		return
		
	var inverse_rotation = -global_rotation
	ammo_ui.rotation = inverse_rotation
	
	# Rotation des carrés
	var carres = [carre1, carre2, carre3]
	for carre in carres:
		if carre:
			carre.rotation = inverse_rotation

# === GESTION DU TIR ET DU RECUL ===

func handle_shooting_detection():
	"""Détecte automatiquement les tirs"""
	if Global.current_ammo < last_ammo_count:
		trigger_recoil()
	last_ammo_count = Global.current_ammo

func trigger_recoil():
	"""Déclenche l'effet de recul"""
	current_spread_time = 0.0
	# Force une mise à jour immédiate des shaders
	update_shader_parameters()

# === GESTION DU SPREAD ===

func update_spread(delta: float):
	"""Met à jour l'écartement des angles selon la courbe"""
	current_spread_time += delta
	
	if not spread_curve or original_positions.is_empty():
		return
	
	var spread_value = spread_curve.sample(current_spread_time)
	var current_distance = spread_value * max_spread_distance
	
	# Applique le spread à chaque angle
	for i in range(min(cursor_angles.size(), angle_directions.size())):
		if cursor_angles[i] and i < original_positions.size():
			var offset = angle_directions[i] * current_distance
			cursor_angles[i].position = original_positions[i] + offset

func reset_crosshair():
	"""Réinitialise les positions (utile pour le debug)"""
	current_spread_time = 10.0
	update_spread(0.0)

# === GESTION DES SHADERS ===

func create_angle_material(angle_id: int) -> ShaderMaterial:
	"""Crée un matériel shader pour un angle spécifique"""
	var material: ShaderMaterial
	
	if crosshair_shader:
		material = crosshair_shader.duplicate()
	else:
		material = ShaderMaterial.new()
		# Le shader doit être assigné dans l'éditeur
		push_warning("Aucun shader assigné au crosshair_shader")
	
	if material:
		material.set_shader_parameter("angle_id", angle_id)
		material.set_shader_parameter("current_ammo", Global.current_ammo)
		# Paramètres par défaut pour la transparence
		material.set_shader_parameter("normal_alpha", 1.0)
		material.set_shader_parameter("transparent_alpha", 0.3)
	
	return material

func apply_material_to_angle(angle_node: Node2D, material: ShaderMaterial):
	"""Applique un matériel à un angle"""
	if not angle_node or not material:
		return
	
	var renderable = find_renderable_node(angle_node)
	if renderable:
		renderable.material = material

func find_renderable_node(node: Node2D) -> Node:
	"""Trouve le nœud qui peut recevoir un matériel"""
	# Vérifie le nœud lui-même
	if node is Sprite2D:
		return node
	
	# Cherche dans les enfants
	for child in node.get_children():
		if child is Sprite2D:
			return child
	
	return null

func update_shader_parameters():
	"""Met à jour les paramètres des shaders"""
	var current_ammo = Global.current_ammo
	
	for i in range(angle_materials.size()):
		if angle_materials[i] and angle_materials[i].shader:
			angle_materials[i].set_shader_parameter("current_ammo", current_ammo)

# === GESTION DE L'AFFICHAGE DES MUNITIONS ===

func update_ammo_display():
	"""Met à jour l'affichage selon les munitions"""
	update_shader_parameters()
	update_crosshair_appearance()

func update_crosshair_appearance():
	"""Change l'apparence générale du viseur selon les munitions"""
	if not self:
		return

	var color := Color.WHITE

	match Global.current_ammo:
		0:
			color = Color(0.5, 0.5, 0.5, 0.8)  # Gris avec un peu de transparence
		1:
			color = Color(1.0, 0.0, 0.0, 0.8)  # Rouge avec transparence
		2:
			color = Color.ORANGE
		3:
			color = Color.YELLOW
		4:
			color = Color.GREEN
		_:
			color = Color.WHITE
	
	modulate = color
	visible = true

	# Mise à jour de la couleur dans les shaders
	for material in angle_materials:
		if material and material.shader:
			material.set_shader_parameter("tint_color", color)

# === FONCTIONS UTILITAIRES ===

func get_angle_count() -> int:
	"""Retourne le nombre d'angles configurés"""
	return cursor_angles.size()

func is_angle_valid(index: int) -> bool:
	"""Vérifie si un angle est valide"""
	return index >= 0 and index < cursor_angles.size() and cursor_angles[index] != null

func get_current_spread_value() -> float:
	"""Retourne la valeur actuelle du spread"""
	if spread_curve:
		return spread_curve.sample(current_spread_time)
	return 0.0
