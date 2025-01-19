extends RayCast2D

@onready var ammo_ui: Control = $Control # Référence au noeud Control
@onready var ammo_label: Label = $Control/Label # Référence au Label
@onready var reload_progress_bar: TextureProgressBar = $Control/TextureProgressBar # Référence à la barre de progression

func _ready():
	# Initialise le texte du Label avec le nombre actuel de munitions
	update_ammo_display()

func _process(_delta):
	if ammo_ui:
		# Applique l'inverse de la rotation globale du RayCast2D à l'ensemble du UI (Control)
		ammo_ui.rotation = -global_rotation

		# Positionne le Control au bout du RayCast2D
		# Utilise la direction du raycast (target_position) pour placer le Control
		ammo_ui.position = global_position + (target_position - global_position).normalized() * (target_position - global_position).length()

# Met à jour l'affichage des munitions
func update_ammo_display():
	if ammo_label:
		ammo_label.text = str(Global.current_ammo)
