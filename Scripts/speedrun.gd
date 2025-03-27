extends CanvasLayer

var time: float = 0.0

func _ready():
	if not Global.timer_initialized:
		reset_timer()
		Global.timer_initialized = true
	else:
		time = Global.speedrun_time

func _physics_process(delta):
	time += delta
	Global.speedrun_time = time
	update_ui()

func reset_timer():
	time = 0.0
	Global.speedrun_time = 0.0
	update_ui()

func update_ui():
	var minutes = int(time) / 60
	var seconds = int(time) % 60
	var centiseconds = int((time - int(time)) * 100)
	$Label.text = "%02d:%02d.%02d" % [minutes, seconds, centiseconds]  # Format à 2 chiffres partout
