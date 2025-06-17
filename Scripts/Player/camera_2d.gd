extends Camera2D

class_name Camera

@export var target: NodePath
@export var offset_y: float = 0.0  # Offset vertical pour voir un peu plus haut
@export var zoom_level: Vector2 = Vector2(2, 2)

# Paramètres de limites
@export_group("Bounds Settings")
@export var bounds_enabled: bool = true
@export var bounds_node_path: NodePath  # Chemin vers le node CameraBounds
@export var bounds_margin: Vector2 = Vector2(50, 50)  # Marge depuis les bords

# Paramètres de suivi
@export_group("Follow Settings")
@export var follow_speed: float = 1.0  # Vitesse de suivi du personnage
@export var smoothing_enabled: bool = true
@export var follow_delay: float = 1.0  # Délai avant que la caméra commence à suivre
@export var offset_horizontal: float = 30.0  # Offset horizontal selon la direction
@export var offset_transition_speed: float = 1.0  # Vitesse de transition de l'offset

# Paramètres de tremblement (shake)
@export_group("Shake Settings")
@export var shake_intensity: float = 4.0  # Intensité du tremblement
@export var shake_frequency: float = 1.0  # Fréquence du tremblement
@export var shake_enabled: bool = true

# Variables internes
@onready var player = get_node(target) if target != NodePath() else null
var bounds_node: CameraBounds = null
var shake_offset: Vector2 = Vector2.ZERO
var time_elapsed: float = 0.0
var target_position: Vector2

# Variables pour le suivi directionnel
var movement_timer: float = 0.0
var current_direction: float = 0.0  # -1 pour gauche, 1 pour droite, 0 pour immobile
var target_offset_x: float = 0.0
var current_offset_x: float = 0.0
var target_offset_y: float = 0.0
var current_offset_y: float = 0.0

# Variables pour l'offset Y dynamique
var base_offset_y: float = 0.0  # Offset Y de base (défini par export)
var dynamic_offset_y: float = 0.0  # Offset Y dynamique (modifiable par les niveaux)
var current_total_offset_y: float = 0.0  # Offset Y total actuel
var target_total_offset_y: float = 0.0  # Offset Y total cible

func _ready():
	if target == NodePath():
		player = get_tree().get_first_node_in_group("Player")
	else:
		player = get_node(target)
	
	if not player:
		print("Aucun personnage assigné à la caméra.")
		return
	
	# Trouver le node de limites
	_find_bounds_node()
	
	# Sauvegarder l'offset Y de base
	base_offset_y = offset_y
	current_total_offset_y = offset_y
	target_total_offset_y = offset_y
	
	# Configuration initiale
	zoom = zoom_level
	
	# Attendre une frame pour que les scripts de niveau puissent modifier l'offset
	await get_tree().process_frame
	
	# Recalculer l'offset total après que les scripts de niveau aient pu le modifier
	target_total_offset_y = base_offset_y + dynamic_offset_y
	current_total_offset_y = target_total_offset_y
	offset_y = current_total_offset_y
	
	# Position initiale de la caméra avec l'offset final
	if player:
		global_position = player.global_position + Vector2(0, offset_y)
		target_position = global_position
		
		# Appliquer les limites à la position initiale
		if bounds_enabled and bounds_node:
			target_position = _apply_bounds_to_position(target_position)
			global_position = target_position
		
		# Réinitialiser les offsets pour commencer centré
		current_offset_x = 0.0
		current_offset_y = 0.0
		target_offset_x = 0.0
		target_offset_y = 0.0

func _find_bounds_node():
	# Chercher le node de limites
	if bounds_node_path != NodePath():
		bounds_node = get_node(bounds_node_path) as CameraBounds
	else:
		# Chercher automatiquement dans la scène
		bounds_node = get_tree().get_first_node_in_group("camera_bounds") as CameraBounds
		if not bounds_node:
			# Chercher par type
			var nodes = get_tree().get_nodes_in_group("camera_bounds")
			for node in nodes:
				if node is CameraBounds:
					bounds_node = node
					break
	
	if bounds_node:
		print("Limites de caméra trouvées : ", bounds_node.name)
		# Connecter le signal de changement des limites
		if not bounds_node.is_connected("bounds_changed", _on_bounds_changed):
			bounds_node.connect("bounds_changed", _on_bounds_changed)
	else:
		print("Aucune limite de caméra trouvée")

func _on_bounds_changed():
	# Réappliquer les limites quand elles changent
	if bounds_enabled and bounds_node:
		target_position = _apply_bounds_to_position(target_position)

func _process(delta):
	if not player:
		return
	
	time_elapsed += delta
	
	# Mettre à jour l'offset Y total
	_update_offset_y(delta)
	
	# Détecter le mouvement du joueur
	_detect_player_movement(delta)
	
	# Calculer la position cible avec offset directionnel
	_calculate_target_position()
	
	# Appliquer les limites si activées
	if bounds_enabled and bounds_node:
		target_position = _apply_bounds_to_position(target_position)
	
	# Appliquer le suivi fluide
	var next_position: Vector2
	if smoothing_enabled:
		next_position = global_position.lerp(target_position, follow_speed * delta)
	else:
		next_position = target_position
	
	# Appliquer les limites à la position finale pour s'assurer qu'elle ne dépasse jamais
	if bounds_enabled and bounds_node:
		next_position = _apply_bounds_to_position(next_position)
	
	global_position = next_position
	
	# Appliquer le tremblement subtil
	if shake_enabled:
		_apply_smooth_shake()

func _apply_bounds_to_position(pos: Vector2) -> Vector2:
	if not bounds_node or bounds_node.get_point_count() < 2:
		return pos
	
	var bounds_rect = bounds_node.get_bounds_rect()
	if bounds_rect.size == Vector2.ZERO:
		return pos
	
	# Calculer la taille de la vue de la caméra
	var viewport_size = get_viewport().get_visible_rect().size
	var camera_size = viewport_size / zoom
	var half_camera_size = camera_size / 2.0
	
	# Calculer les limites strictes
	var min_x = bounds_rect.position.x + half_camera_size.x + bounds_margin.x
	var max_x = bounds_rect.position.x + bounds_rect.size.x - half_camera_size.x - bounds_margin.x
	var min_y = bounds_rect.position.y + half_camera_size.y + bounds_margin.y
	var max_y = bounds_rect.position.y + bounds_rect.size.y - half_camera_size.y - bounds_margin.y
	
	# S'assurer que les limites sont cohérentes
	if max_x < min_x:
		var center_x = (bounds_rect.position.x + bounds_rect.position.x + bounds_rect.size.x) / 2
		min_x = center_x
		max_x = center_x
	if max_y < min_y:
		var center_y = (bounds_rect.position.y + bounds_rect.position.y + bounds_rect.size.y) / 2
		min_y = center_y
		max_y = center_y
	
	# Appliquer les limites de manière stricte
	var constrained_pos = Vector2(
		clamp(pos.x, min_x, max_x),
		clamp(pos.y, min_y, max_y)
	)
	
	return constrained_pos

# Fonction pour définir manuellement les limites
func set_bounds_node(bounds: CameraBounds):
	bounds_node = bounds
	if bounds_node and not bounds_node.is_connected("bounds_changed", _on_bounds_changed):
		bounds_node.connect("bounds_changed", _on_bounds_changed)

# Fonction pour activer/désactiver les limites
func set_bounds_enabled(enabled: bool):
	bounds_enabled = enabled

# Reste de votre code existant...
func _update_offset_y(delta):
	# Calculer l'offset Y total cible
	target_total_offset_y = base_offset_y + dynamic_offset_y
	
	# Interpoler vers l'offset cible pour une transition fluide
	current_total_offset_y = lerp(current_total_offset_y, target_total_offset_y, offset_transition_speed * delta)
	
	# Mettre à jour offset_y pour qu'il soit utilisé dans les calculs
	offset_y = current_total_offset_y

func _detect_player_movement(delta):
	var is_moving_right = Input.is_action_pressed("Move_Right")
	var is_moving_left = Input.is_action_pressed("Move_Left")
	
	var new_direction = 0.0
	if is_moving_right:
		new_direction = 1.0
	elif is_moving_left:
		new_direction = -1.0
	
	# Si la direction change ou si on commence à bouger
	if new_direction != current_direction:
		current_direction = new_direction
		movement_timer = 0.0
		
		# Définir l'offset cible selon la direction horizontale
		if current_direction > 0:  # Vers la droite
			target_offset_x = offset_horizontal
		elif current_direction < 0:  # Vers la gauche
			target_offset_x = -offset_horizontal
		else:
			target_offset_x = 0.0
	
	# Incrémenter le timer seulement si on bouge
	if current_direction != 0:
		movement_timer += delta
	else:
		movement_timer = 0.0

func _calculate_target_position():
	# Interpoler les offsets actuels vers les offsets cibles
	current_offset_x = lerp(current_offset_x, target_offset_x, offset_transition_speed * get_process_delta_time())
	current_offset_y = lerp(current_offset_y, target_offset_y, offset_transition_speed * get_process_delta_time())
	
	# Position de base du joueur (utilise l'offset_y mis à jour)
	var base_position = player.global_position + Vector2(0, offset_y)
	
	# Si on est en mouvement et que le délai est écoulé, appliquer l'offset directionnel
	if movement_timer >= follow_delay:
		target_position = base_position + Vector2(current_offset_x, current_offset_y)
	else:
		# Pendant le délai de mouvement, appliquer seulement l'offset Y (vertical) et les influences externes
		# mais pas l'offset X directionnel
		target_position = base_position + Vector2(current_offset_x, current_offset_y)

func _apply_smooth_shake():
	# Utiliser des fonctions sinusoidales pour un tremblement très doux
	var shake_x = sin(time_elapsed * shake_frequency) * shake_intensity
	var shake_y = cos(time_elapsed * shake_frequency * 0.7) * shake_intensity * 0.5
	
	shake_offset = Vector2(shake_x, shake_y)
	offset = shake_offset

# Fonction pour déclencher un tremblement temporaire (ex: lors d'impacts)
func trigger_shake(intensity: float, duration: float):
	var tween = create_tween()
	var original_intensity = shake_intensity
	
	shake_intensity = intensity
	tween.tween_method(_reduce_shake, intensity, original_intensity, duration)

func _reduce_shake(value: float):
	shake_intensity = value

# Fonction pour définir un offset Y dynamique (avec transition fluide)
func set_dynamic_offset_y(new_offset: float):
	dynamic_offset_y = new_offset
	# Si c'est au début (pas encore de _ready terminé), appliquer instantanément
	if not is_inside_tree() or get_tree().current_scene.get_tree().current_frame <= 2:
		set_dynamic_offset_y_instant(new_offset)
	else:
		# Si le joueur ne bouge pas, forcer la mise à jour de la position
		if movement_timer < follow_delay:
			_force_position_update()

# Fonction pour définir un offset Y dynamique avec transition instantanée
func set_dynamic_offset_y_instant(new_offset: float):
	dynamic_offset_y = new_offset
	current_total_offset_y = base_offset_y + dynamic_offset_y
	offset_y = current_total_offset_y
	# Mettre à jour immédiatement la position
	_force_position_update()

# Fonction pour forcer la mise à jour de la position (utilisée lors des changements d'offset)
func _force_position_update():
	if player:
		target_position = player.global_position + Vector2(0, offset_y)
		# Appliquer les limites
		if bounds_enabled and bounds_node:
			target_position = _apply_bounds_to_position(target_position)
		# Appliquer immédiatement, même avec smoothing
		global_position = target_position

# Fonction pour ajouter un offset Y temporaire (s'additionne au dynamic_offset_y)
func add_temp_offset_y(temp_offset: float):
	dynamic_offset_y += temp_offset

# Fonction pour réinitialiser l'offset Y dynamique
func reset_dynamic_offset_y():
	dynamic_offset_y = 0.0

# Fonction pour obtenir l'offset Y total actuel
func get_current_offset_y() -> float:
	return current_total_offset_y
