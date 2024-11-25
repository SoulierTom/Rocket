extends Node2D

var is_using_gamepad = false

var target_pos = Vector2.RIGHT
var last_joystick_vector = Vector2.RIGHT

# Initialisation lors du démarrage de la scène
func _ready():
	# Met cet objet en haut de la hiérarchie des rendus (dessiné devant les autres)
	set_as_top_level(true)
	# Initialiser les positions
	target_pos = position
	

# Mise à jour à chaque frame physique
func _physics_process(delta):
	
	
	
	
	# Obtenir la position du personnage (le parent de ce Sprite)
	var character_pos = get_parent().position

	# Attacher le bras à une position relative autour du personnage
	position.x = lerp(position.x, character_pos.x - 10, 0.8)
	position.y = lerp(position.y, character_pos.y, 0.8)

	var mouse_pos = get_global_mouse_position()

	# Vérifier si le joystick est utilisé
	var joystick_vector = Input.get_vector("Look_Left", "Look_Right", "Look_Up", "Look_Down") 
	
	
	
	if is_using_gamepad :
		if joystick_vector.length() > 0.1:
			target_pos = character_pos + joystick_vector * 500
			last_joystick_vector = joystick_vector
			look_at(target_pos)
		else :
			target_pos = character_pos + last_joystick_vector * 500
			look_at(target_pos)
	else:
		# La souris bouge, utiliser sa position
			target_pos = mouse_pos
			look_at(target_pos)

	print(last_joystick_vector)

func _input(event):
	# Vérifier si l'événement vient d'une manette
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		is_using_gamepad = true  # La manette est en cours d'utilisation

	# Si une autre entrée (clavier/souris) est détectée, désactiver la manette
	elif event is InputEventMouse or event is InputEventKey:
		is_using_gamepad = false  # Retour à une autre méthode d'entrée
