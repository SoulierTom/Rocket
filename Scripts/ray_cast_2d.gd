extends RayCast2D
@onready var ammo_ui: Control = $Control # Référence au noeud Control
@onready var ammo_sprite: Sprite2D = $Control/arm_sprite # Référence au Sprite2D
@onready var reload_progress_bar: TextureProgressBar = $Control/TextureProgressBar # Référence à la barre de progression

func _ready():
	# Initialise l'affichage des munitions
	update_ammo_display()

func _process(delta):
	if ammo_ui:
		# Applique l'inverse de la rotation globale du RayCast2D à l'ensemble du UI (Control)
		ammo_ui.rotation = -global_rotation
		# Positionne le Control au bout du RayCast2D
		# Utilise la direction du raycast (target_position) pour placer le Control
		ammo_ui.position = global_position + (target_position - global_position).normalized() * (target_position - global_position).length()

# Met à jour l'affichage des munitions
func update_ammo_display():
	if ammo_sprite:
		# Ici vous pouvez modifier le sprite selon les munitions
		# Par exemple, changer la texture ou la modulation de couleur
		# ammo_sprite.texture = load("res://path/to/ammo_texture.png")
		# ou modifier la couleur selon le nombre de munitions
		update_sprite_based_on_ammo()

# Fonction pour adapter le sprite selon les munitions
func update_sprite_based_on_ammo():
	if not ammo_sprite:
		return
	
	# Exemple : changer la couleur du sprite selon le niveau de munitions
	if Global.current_ammo <= 0:
		ammo_sprite.modulate = Color.RED # Rouge si plus de munitions
	elif Global.current_ammo <= 2:
		ammo_sprite.modulate = Color.YELLOW # Jaune si peu de munitions
	else:
		ammo_sprite.modulate = Color.WHITE # Blanc si assez de munitions
	
	# Ou vous pouvez changer la texture complètement :
	# match Global.current_ammo:
	#     0: ammo_sprite.texture = load("res://sprites/empty_ammo.png")
	#     1,2,3,4,5: ammo_sprite.texture = load("res://sprites/low_ammo.png")
	#     _: ammo_sprite.texture = load("res://sprites/full_ammo.png")
