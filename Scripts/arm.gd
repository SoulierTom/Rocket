extends Node2D

# Variables propres au mouvement du bras
var is_using_gamepad = false
var last_joystick_vector = Vector2.RIGHT

# Position du bras
@export var pos_arm_x: float = -4.0
@export var pos_arm_y: float = 3.0

# Le recul du tir
signal projectile_fired
var recoiling: bool = false
@export var recoil_force: int = 25
var recoil_vector: Vector2 = Vector2.ZERO
@export var recoil_duration: float = 0.025

@export var reload_time: float = 3.0 # Temps de recharge en secondes
@onready var cooldown: Timer = $Cooldown # Cooldown entre 2 tirs
var reloading: bool = false # Indique si une recharge est en cours

# Permet d'utiliser la Scene Rocket
const RocketScene = preload("res://Scenes/Rocket.tscn")
@onready var shooting_point: Marker2D = $Sprite2D/ShootingPoint

# Permet de générer l'explosion
@export var explosion_scene: PackedScene

func _ready():
	# Met cet objet en haut de la hiérarchie des rendus (dessiné devant les autres)
	set_as_top_level(true)

func _physics_process(_delta):
	# Obtenir la position du Player (le parent de ce Sprite)
	var character_pos = get_parent().position

	var dir_arm = (Global.target_pos - position).normalized()
	recoil_vector = -dir_arm * recoil_force

	# Attacher le bras à une position relative autour du Player
	position.x = lerp(position.x, character_pos.x + pos_arm_x, 0.85)
	position.y = lerp(position.y, character_pos.y + pos_arm_y, 0.85)

	if recoiling: # Durant une courte durée après avoir tiré, le bras subit du recul
		position.x = lerp(position.x, character_pos.x + pos_arm_x + recoil_vector.x, 0.8)
		position.y = lerp(position.y, character_pos.y + pos_arm_y + recoil_vector.y, 0.8)

	var mouse_pos = get_global_mouse_position()
	var joystick_vector = Input.get_vector("Look_Left", "Look_Right", "Look_Up", "Look_Down")

	# Direction que pointe le bras, avec la souris ou le joystick
	if is_using_gamepad:
		if joystick_vector.length() > 0.1:
			Global.target_pos = character_pos + joystick_vector * 500
			last_joystick_vector = joystick_vector
			look_at(Global.target_pos)
		else: # Quand le joystick est relâché il pointe vers la précédente direction
			Global.target_pos = character_pos + last_joystick_vector * 500
			look_at(Global.target_pos)
	else: # La souris bouge, utiliser sa position
		Global.target_pos = mouse_pos
		look_at(Global.target_pos)

func _input(event):
	# Vérifier si l'événement vient d'une manette
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		is_using_gamepad = true

	# Si une autre entrée (clavier/souris) est détectée, désactiver la manette
	elif event is InputEventMouse or event is InputEventKey:
		is_using_gamepad = false

	# Appel la fonction shoot si le joueur tire et que le bras est rechargé
	if event.is_action_pressed("Shoot") and cooldown.is_stopped():
		if Global.current_ammo > 0:
			shoot(RocketScene)
			projectile_fired.emit()
			Global.current_ammo -= 1

			# Met à jour la barre de progression et le label
			$RayCast2D/Control/TextureProgressBar.update_progress(Global.current_ammo)
			$RayCast2D.update_ammo_display()

			print("Munitions dans le chargeur :", Global.current_ammo)

			# Si les munitions sont inférieures à 3, démarrer le rechargement
			if Global.current_ammo < 3 and not reloading:
				print("Chargeur presque vide ! En cours de recharge...")
				reloading = true
				start_reload()

			recoiling = true
			await get_tree().create_timer(recoil_duration).timeout
			recoiling = false
		else:
			print("Chargeur vide ! En cours de recharge...")

func start_reload():
	if reloading:
		$RayCast2D/Control/TextureProgressBar.update_progress(Global.current_ammo) # Barre visible au début du rechargement
		$RayCast2D.update_ammo_display() # Met à jour le label
		await get_tree().create_timer(reload_time).timeout
		Global.current_ammo = Global.magazine_size
		$RayCast2D/Control/TextureProgressBar.update_progress(Global.current_ammo) # Met à jour la barre après rechargement
		$RayCast2D.update_ammo_display() # Met à jour le label
		reloading = false
		print("Chargeur rechargé :", Global.current_ammo)


# Génére une Rocket
func shoot(projectile: PackedScene) -> void:
	var projectile_instance = projectile.instantiate()
	projectile_instance.position = shooting_point.global_position
	projectile_instance.direction = global_position.direction_to(Global.target_pos)
	add_child(projectile_instance)
	$Tir.play()
	# Lance un cooldown qui désactive le tir
	cooldown.start()

# Génère l'explosion
func create_explosion(explosion_position: Vector2) -> void:
	if explosion_scene: # Vérifie que la scene existe
		var explosion_instance = explosion_scene.instantiate()
		explosion_instance.global_position = explosion_position
		add_child(explosion_instance) # Ajoute l'explosion à la scène
		$Explosion.play()
