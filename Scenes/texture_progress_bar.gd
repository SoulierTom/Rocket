extends TextureProgressBar

@export var max_ammo: int = 3 # Nombre maximum de munitions dans le chargeur
@export var reload_time: float = 3.0 # Temps de rechargement total (en secondes)

var reload_timer: Timer

func _ready():
	# Initialisation
	visible = false
	value = 0
	max_value = 100
	reload_timer = Timer.new()
	reload_timer.wait_time = 0.03 # 30 millisecondes
	reload_timer.one_shot = false # Le timer doit se répéter
	add_child(reload_timer)
	reload_timer.connect("timeout", Callable(self, "_on_reload_tick"))

# Appelé lorsque le compteur de munitions est mis à jour
func update_progress(current_ammo: int):
	if current_ammo < max_ammo and not visible:
		# Si les munitions sont en dessous du maximum, afficher la barre
		visible = true
		value = 0
		reload_timer.start()
	elif current_ammo == max_ammo:
		# Si les munitions sont au maximum, cacher la barre
		reload_timer.stop()
		visible = false

# Mise à jour progressive de la barre
func _on_reload_tick():
	# Incrémenter la valeur de la barre en fonction du temps de rechargement
	value += 100 / (reload_time / 0.03)
	if value >= 100:
		value = 100
		reload_timer.stop()
