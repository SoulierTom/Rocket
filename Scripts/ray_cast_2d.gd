extends RayCast2D

@onready var ammo_label: Label = $Label # Chemin vers le Label dans le RayCast2D

func _ready():
	# Initialise le texte du Label avec le nombre actuel de munitions
	update_ammo_display()

func _process(_delta):
	if ammo_label:
		# Applique l'inverse de la rotation globale du RayCast2D au Label
		ammo_label.rotation = -global_rotation

# Met à jour l'affichage des munitions
func update_ammo_display():
	if ammo_label:
		ammo_label.text = str(Global.current_ammo)
