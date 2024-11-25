extends Node2D

var is_using_gamepad = false

# Variables pour gérer les cibles
var last_target_pos: Vector2  # Dernière position cible (joystick ou souris)
var previous_mouse_pos: Vector2  # Position de la souris au dernier frame

# Initialisation lors du démarrage de la scène
func _ready():
	# Met cet objet en haut de la hiérarchie des rendus (dessiné devant les autres)
	set_as_top_level(true)
	# Initialiser les positions
	last_target_pos = position
	previous_mouse_pos = get_global_mouse_position()

# Mise à jour à chaque frame physique
func _physics_process(delta):
	# Vérifier que le parent existe bien
	if not get_parent():
		return  # Si aucun parent, ne rien faire pour éviter une erreur

	# Obtenir la position du personnage (le parent de ce Sprite)
	var character_position = get_parent().position

	# Attacher le bras à une position relative autour du personnage
	position.x = lerp(position.x, character_position.x + 10, 0.5)
	position.y = lerp(position.y, character_position.y + 10, 0.5)

	# Détecter si la souris est en mouvement
	var current_mouse_pos = get_global_mouse_position()
	var is_mouse_moving = current_mouse_pos != previous_mouse_pos  # La souris bouge-t-elle ?

	# Vérifier si le joystick est utilisé
	var joystick_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")  # Change les noms si besoin
	if joystick_vector.length() > 0.1:
		# Le joystick est actif, utiliser sa direction
		last_target_pos = character_position + joystick_vector * 100  # Ajuster l'échelle si nécessaire
	elif is_mouse_moving:
		# La souris bouge, utiliser sa position
			last_target_pos = current_mouse_pos

	# Mettre à jour la position précédente de la souris
	previous_mouse_pos = current_mouse_pos

	# Faire en sorte que le bras regarde toujours dans la direction de la cible
	look_at(last_target_pos)
	
func _input(event):
	# Vérifier si l'événement vient d'une manette
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		is_using_gamepad = true  # La manette est en cours d'utilisation

	# Si une autre entrée (clavier/souris) est détectée, désactiver la manette
	elif event is InputEventMouse or event is InputEventKey:
		is_using_gamepad = false  # Retour à une autre méthode d'entrée
