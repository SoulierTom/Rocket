extends Area2D

# Variables de vibration
var vibration_duration: float = 0.2  # Durée totale plus longue
var initial_vibration_strength: float = 0.6  # Vibration forte au début
var vibration_decay_rate: float = 0.1  # Vitesse de diminution

@onready var player: CharacterBody2D = $".."

func _ready():
	# Initialisation
	area_entered.connect(_on_area_entered)
	print("System ready - Waiting for interactions...")
	
	# Vérification des références
	if player == null:
		printerr("Player is null in _ready(). Check the path!")
	else:
		print("Player initialized successfully:", player.name)

func _on_area_entered(area):
	# Gestion des impacts
	if area.is_in_group("boom"):
		print("Impact detected!")
		if Global.VBR:
			_trigger_decaying_vibration()


func _trigger_decaying_vibration():
	if not Global.VBR:
		return
	
	var joypads = Input.get_connected_joypads()
	if joypads.size() == 0:
		print("No controller connected - skipping vibration")
		return
	
	var joypad_id = joypads[0]
	var current_strength = initial_vibration_strength
	var elapsed_time = 0.0
	
	# Vibration initiale forte
	Input.start_joy_vibration(joypad_id, current_strength, current_strength, vibration_duration)
	print("Starting strong vibration: ", current_strength)
	
	# Boucle de diminution progressive
	while current_strength > 0 and elapsed_time < vibration_duration:
		await get_tree().create_timer(0.05).timeout  # Mise à jour toutes les 0.05s
		elapsed_time += 0.05
		current_strength = max(0, current_strength - vibration_decay_rate)
		Input.start_joy_vibration(joypad_id, current_strength, current_strength, 0.05)
		print("Current vibration strength: ", current_strength)
	
	# Arrêt final
	Input.stop_joy_vibration(joypad_id)
	print("Vibration ended")
