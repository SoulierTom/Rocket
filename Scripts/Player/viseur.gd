extends RayCast2D
@onready var ammo_ui: Control = $Control # Référence au noeud Control
@onready var carre1: ColorRect = $"Carré1"
@onready var carre2: ColorRect = $"Carré2"
@onready var carre3: ColorRect = $"Carré3"
@onready var viseur = $"."
@export var pos_viseur_x: float = 0
@export var pos_viseur_y: float = 0

func _ready():
	# Initialise l'affichage des munitions
	update_ammo_display()
	viseur.z_index = 10

func _process(delta):
	position.x = pos_viseur_x
	position.y = pos_viseur_y
	if ammo_ui:
		# Applique l'inverse de la rotation globale du RayCast2D à l'ensemble du UI (Control)
		ammo_ui.rotation = -global_rotation
		# Positionne le Control au bout du RayCast2D
		# Utilise la direction du raycast (target_position) pour placer le Control
		ammo_ui.position = global_position + (target_position - global_position).normalized() * (target_position - global_position).length()
		
		# Applique la même rotation aux carrés pour qu'ils restent horizontaux
		if carre1:
			carre1.rotation = -global_rotation
		if carre2:
			carre2.rotation = -global_rotation
		if carre3:
			carre3.rotation = -global_rotation
	
	# Met à jour l'affichage en temps réel
	update_ammo_display()

func _physics_process(_delta):
	look_at(Global.target_pos)

# Met à jour l'affichage des munitions
func update_ammo_display():
	if viseur:
		update_sprite_based_on_ammo()

# Fonction pour adapter le sprite selon les munitions (max 3)
func update_sprite_based_on_ammo():
	if not viseur:
		return
	
	# Adaptation visuelle selon le nombre de munitions (0 à 3)
	match Global.current_ammo:
		0:
			# Aucune munition - curseur rouge et légèrement transparent
			viseur.modulate = Color(1.0, 0.0, 0.0, 0.6)  # Rouge avec 60% d'opacité
		1:
			# 1 munition - orange
			viseur.visible = true
			viseur.modulate = Color.ORANGE
		2:
			# 2 munitions - jaune
			viseur.visible = true
			viseur.modulate = Color.YELLOW
		3:
			# 3 munitions (max) - vert
			viseur.visible = true
			viseur.modulate = Color.GREEN
		_:
			# Cas par défaut
			viseur.visible = true
			viseur.modulate = Color.WHITE
