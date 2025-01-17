extends RayCast2D

@onready var ammo_label: Label = $Label # Chemin vers le Label dans le RayCast2D

func _ready():
	# Initialise le texte du Label avec le nombre actuel de munitions
	update_ammo_display()

# Met à jour l'affichage des munitions
func update_ammo_display():
	if ammo_label:
		ammo_label.text = str(Global.current_ammo)
