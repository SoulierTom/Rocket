extends CanvasLayer

var time: float = 0.0

func _ready():
	# Ne réinitialise le timer que si c'est la première fois qu'il est lancé (niveau "Level_1")
	if not Global.timer_initialized:
		Global.timer_initialized = true
		reset_timer_if_needed()
	else:
		# Récupère le temps global si le timer a déjà été lancé
		time = Global.speedrun_time

func _physics_process(delta):
	time += delta
	Global.speedrun_time = time  # Met à jour la variable globale avec le temps accumulé
	update_ui()

func reset_timer_if_needed():
	# Réinitialise le timer uniquement si c'est le niveau "Level_1"
	var current_scene_name = get_tree().current_scene.name
	if current_scene_name == "Level_1":
		reset_timer()

func reset_timer():
	time = 0.0
	Global.speedrun_time = time
	update_ui()

func update_ui():
	# Convertir le temps total en minutes et secondes
	var minutes = int(time) / 60
	var seconds = int(time) % 60

	# Formater le temps sous la forme "minute:seconde"
	var formatted_time = "%d:%02d" % [minutes, seconds]
	$Label.text = formatted_time
