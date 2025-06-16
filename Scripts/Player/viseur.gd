extends RayCast2D

@onready var ammo_ui: Control = $Control
@onready var carre1: ColorRect = $"Carré1"
@onready var carre2: ColorRect = $"Carré2"
@onready var carre3: ColorRect = $"Carré3"

# Références aux angles du curseur
@onready var cursor_middle: Node2D = $Control/CursorMiddle
@onready var cursor_angle: Node2D = $Control/CursorAngle
@onready var cursor_angle2: Node2D = $Control/CursorAngle2
@onready var cursor_angle3: Node2D = $Control/CursorAngle3
@onready var cursor_angle4: Node2D = $Control/CursorAngle4

@onready var viseur = $"."

@export var pos_viseur_x: float = 0
@export var pos_viseur_y: float = 0

# Variables pour l'effet de recul
@export var recoil_distance: float = 20.0  # Distance d'éloignement des angles
@export var recoil_duration: float = 0.2   # Durée de l'animation de recul
@export var return_duration: float = 0.3   # Durée du retour à la position normale

# Courbe pour gérer la distance des angles dans le temps
@export var spread_curve: Curve
@export var max_spread_distance: float = 30.0  # Distance maximale des angles
@export var spread_recovery_speed: float = 2.0  # Vitesse de récupération de la précision

# Positions d'origine des angles (à définir dans _ready)
var original_positions: Dictionary = {}

# Variables pour la gestion du recul et de la précision
var last_ammo_count: int = 0
var current_spread_time: float = 0.0  # Temps actuel pour la courbe de spread

func _ready():
	update_ammo_display()
	viseur.z_index = 10
	
	# Sauvegarde les positions d'origine des angles
	if cursor_angle:
		original_positions["angle1"] = cursor_angle.position
	if cursor_angle2:
		original_positions["angle2"] = cursor_angle2.position
	if cursor_angle3:
		original_positions["angle3"] = cursor_angle3.position
	if cursor_angle4:
		original_positions["angle4"] = cursor_angle4.position
	
	# Initialise le compteur de munitions
	last_ammo_count = Global.current_ammo
	
	# Crée une courbe par défaut si elle n'existe pas
	if not spread_curve:
		spread_curve = Curve.new()
		# Courbe qui commence à 0, monte rapidement puis redescend
		spread_curve.add_point(Vector2(0.0, 0.0))  # Début : pas de spread
		spread_curve.add_point(Vector2(0.1, 1.0))  # Pic rapide
		spread_curve.add_point(Vector2(1.0, 0.0))  # Retour à 0 après 1 seconde

func _process(delta):
	position.x = pos_viseur_x
	position.y = pos_viseur_y
	
	# Détecte si le nombre de munitions a diminué (= tir)
	if Global.current_ammo < last_ammo_count:
		trigger_recoil()
		current_spread_time = 0.0  # Reset le temps de spread
	last_ammo_count = Global.current_ammo
	
	# Met à jour le spread basé sur le temps et la courbe
	current_spread_time += delta
	update_crosshair_spread()
	
	if ammo_ui:
		ammo_ui.rotation = -global_rotation
		
		if carre1:
			carre1.rotation = -global_rotation
		if carre2:
			carre2.rotation = -global_rotation
		if carre3:
			carre3.rotation = -global_rotation
	
	update_ammo_display()

func _physics_process(_delta):
	look_at(Global.target_pos)

# Met à jour la position des angles selon la courbe de spread
func update_crosshair_spread():
	if not spread_curve:
		return
	
	# Calcule la valeur actuelle du spread selon la courbe
	var spread_value = spread_curve.sample(current_spread_time)
	var current_distance = spread_value * max_spread_distance
	
	# Applique la distance aux angles selon leurs directions
	if cursor_angle and original_positions.has("angle1"):
		var offset = Vector2(-current_distance, -current_distance).normalized() * current_distance
		cursor_angle.position = original_positions["angle1"] + offset
	
	if cursor_angle2 and original_positions.has("angle2"):
		var offset = Vector2(current_distance, -current_distance).normalized() * current_distance
		cursor_angle2.position = original_positions["angle2"] + offset
	
	if cursor_angle3 and original_positions.has("angle3"):
		var offset = Vector2(current_distance, current_distance).normalized() * current_distance
		cursor_angle3.position = original_positions["angle3"] + offset
	
	if cursor_angle4 and original_positions.has("angle4"):
		var offset = Vector2(-current_distance, current_distance).normalized() * current_distance
		cursor_angle4.position = original_positions["angle4"] + offset

# Fonction à appeler quand le joueur tire (maintenant automatique)
func trigger_recoil():
	# Réinitialise le temps de spread pour redéclencher la courbe
	current_spread_time = 0.0

# Fonction pour réinitialiser les positions (utile pour le debug)
func reset_crosshair():
	current_spread_time = 10.0  # Force la fin de la courbe
	update_crosshair_spread()

func update_ammo_display():
	if viseur:
		update_sprite_based_on_ammo()

func update_sprite_based_on_ammo():
	if not viseur:
		return
	
	match Global.current_ammo:
		0:
			viseur.modulate = Color(1.0, 0.0, 0.0, 0.6)
		1:
			viseur.visible = true
			viseur.modulate = Color.ORANGE
		2:
			viseur.visible = true
			viseur.modulate = Color.YELLOW
		3:
			viseur.visible = true
			viseur.modulate = Color.GREEN
		_:
			viseur.visible = true
			viseur.modulate = Color.WHITE
