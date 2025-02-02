extends Node2D

@onready var player = $".."
@onready var reload_timer: Timer = $ReloadTimer  # Timer de rechargement

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
var remaining_reload_time: float = 0.0  # Temps restant du rechargement

# Permet d'utiliser la Scene Rocket
const RocketScene = preload("res://Scenes/Rocket.tscn")
@onready var shooting_point: Marker2D = $Sprite2D/ShootingPoint

# Permet de générer l'explosion
@export var explosion_scene: PackedScene

func _ready():
	set_as_top_level(true)  # Dessine l'objet devant les autres
	reload_timer.wait_time = reload_time  # Durée du rechargement
	reload_timer.one_shot = true  # Le timer ne boucle pas
	reload_timer.connect("timeout", Callable(self, "_on_ReloadTimer_timeout"))

func _physics_process(_delta):
	var character_pos = get_parent().position
	var dir_arm = (Global.target_pos - position).normalized()
	recoil_vector = -dir_arm * recoil_force
	position.x = lerp(position.x, character_pos.x + pos_arm_x, 0.85)
	position.y = lerp(position.y, character_pos.y + pos_arm_y, 0.85)

	if recoiling:
		position.x = lerp(position.x, character_pos.x + pos_arm_x + recoil_vector.x, 0.8)
		position.y = lerp(position.y, character_pos.y + pos_arm_y + recoil_vector.y, 0.8)

	var mouse_pos = get_global_mouse_position()
	var joystick_vector = Input.get_vector("Look_Left", "Look_Right", "Look_Up", "Look_Down")

	if is_using_gamepad:
		if joystick_vector.length() > 0.1:
			Global.target_pos = character_pos + joystick_vector * 500
			last_joystick_vector = joystick_vector
			look_at(Global.target_pos)
		else:
			Global.target_pos = character_pos + last_joystick_vector * 500
			look_at(Global.target_pos)
	else:
		Global.target_pos = mouse_pos
		look_at(Global.target_pos)

func _input(event):
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		is_using_gamepad = true
	elif event is InputEventMouse or event is InputEventKey:
		is_using_gamepad = false

	if event.is_action_pressed("Shoot") and cooldown.is_stopped():
		if Global.current_ammo > 0:
			shoot(RocketScene)
			projectile_fired.emit()
			Global.current_ammo -= 1
			$RayCast2D/Control/TextureProgressBar.update_progress(Global.current_ammo)
			$RayCast2D.update_ammo_display()
			print("Munitions dans le chargeur :", Global.current_ammo)

			if Global.current_ammo < 3 and not reloading:
				print("Chargeur presque vide ! En cours de recharge...")
				reloading = true
				start_reload()

			recoiling = true
			await get_tree().create_timer(recoil_duration).timeout
			recoiling = false
		else:
			print("Chargeur vide ! En cours de recharge...")

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		reset_ammo()

func reset_ammo():
	Global.current_ammo = Global.magazine_size
	print("Munitions réinitialisées :", Global.current_ammo)

func start_reload():
	if not reloading:
		return

	reload_timer.start()  # Démarrer le timer normalement
	remaining_reload_time = reload_time  # Sauvegarde le temps total
	print("Rechargement en cours...")

func _on_reload_timer_timeout():
	if not get_tree().paused:
		Global.current_ammo = Global.magazine_size
		$RayCast2D/Control/TextureProgressBar.update_progress(Global.current_ammo)
		$RayCast2D.update_ammo_display()
		reloading = false
		print("Chargeur rechargé :", Global.current_ammo)

func _process(_delta):
	if get_tree().paused:
		if reload_timer.time_left > 0:
			remaining_reload_time = reload_timer.time_left
			reload_timer.stop()
	else:
		if reloading and reload_timer.is_stopped() and remaining_reload_time > 0:
			reload_timer.start(remaining_reload_time)
			remaining_reload_time = 0  # On remet à zéro après avoir repris


func shoot(projectile: PackedScene) -> void:
	var projectile_instance = projectile.instantiate()
	projectile_instance.position = player.global_position
	projectile_instance.direction = global_position.direction_to(Global.target_pos)
	add_child(projectile_instance)
	$Tir.play()
	cooldown.start()

func create_explosion(explosion_position: Vector2) -> void:
	if explosion_scene:
		var explosion_instance = explosion_scene.instantiate()
		explosion_instance.global_position = explosion_position
		add_child(explosion_instance)
		$Explosion.play()
