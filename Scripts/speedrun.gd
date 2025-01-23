extends CanvasLayer

var time: float = 0.0

func _ready():
	reset_timer_if_needed()

func _physics_process(delta):
	time += delta
	update_ui()

func reset_timer_if_needed():
	# Vérifie si la scène actuelle est "Level_1"
	var current_scene_name = get_tree().current_scene.name
	if current_scene_name == "Level_1":
		reset_timer()

func reset_timer():
	time = 0.0
	Global.speedrun_time = "0.00"  # Réinitialise également la variable globale
	update_ui()

func update_ui():
	# Formater le temps avec deux décimales
	var formatted_time = str(time)
	var decimal_index = formatted_time.find(".")
	if decimal_index > 0:
		formatted_time = formatted_time.left(decimal_index + 3)  # Deux décimales uniquement
	
	Global.speedrun_time = formatted_time
	$Label.text = formatted_time
