extends RayCast2D
@onready var ammo_ui: Control = $Control # Référence au noeud Control
@onready var ammo_sprite: Sprite2D = $Control/arm_sprite # Référence au Sprite2D
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
	
	# Met à jour l'affichage en temps réel
	update_ammo_display()

func _physics_process(_delta):
	look_at(Global.target_pos)

# Met à jour l'affichage des munitions
func update_ammo_display():
	if ammo_sprite:
		update_sprite_based_on_ammo()

# Fonction pour adapter le sprite selon les munitions (max 3)
func update_sprite_based_on_ammo():
	if not ammo_sprite:
		return
	
	# Adaptation visuelle selon le nombre de munitions (0 à 3)
	match Global.current_ammo:
		0:
			# Aucune munition - rouge ou texture vide
			ammo_sprite.visible = false
			# ammo_sprite.texture = load("res://sprites/ammo_empty.png")
		1:
			# 1 munition - orange
			ammo_sprite.modulate = Color.ORANGE
			# ammo_sprite.texture = load("res://sprites/ammo_low.png")
		2:
			# 2 munitions - jaune
			ammo_sprite.modulate = Color.YELLOW
			# ammo_sprite.texture = load("res://sprites/ammo_medium.png")
		3:
			# 3 munitions (max) - vert ou blanc
			ammo_sprite.visible = true
			ammo_sprite.modulate = Color.GREEN
			# ammo_sprite.texture = load("res://sprites/ammo_full.png")
		_:
			# Cas par défaut (ne devrait pas arriver avec max 3)
			ammo_sprite.modulate = Color.WHITE
