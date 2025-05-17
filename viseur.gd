extends RayCast2D

@onready var ammo_ui: Control = $Control # Référence au noeud Control
@onready var ammo_label: Label = $Control/Label # Référence au Label
@onready var viseur = $"."
@export var pos_viseur_x: float = 0
@export var pos_viseur_y: float = 0


func _ready():
	# Initialise le texte du Label avec le nombre actuel de munitions
	update_ammo_display()
	viseur.z_index = 10


func _process(_delta):
	position.x = pos_viseur_x
	position.y = pos_viseur_y
	if ammo_ui:
		# Applique l'inverse de la rotation globale du RayCast2D à l'ensemble du UI (Control)
		ammo_ui.rotation = -global_rotation

		# Positionne le Control au bout du RayCast2D
		# Utilise la direction du raycast (target_position) pour placer le Control
		ammo_ui.position = global_position + (target_position - global_position).normalized() * (target_position - global_position).length()
	if ammo_label:
		ammo_label.text = str(Global.current_ammo)
# Met à jour l'affichage des munitions


func _physics_process(_delta):
	look_at(Global.target_pos)


func update_ammo_display():
	if ammo_label:
		ammo_label.text = str(Global.current_ammo)
