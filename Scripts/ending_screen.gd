extends Control

@onready var ending_screen: Control = $"."
@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer

# Variables pour les seuils de temps des médailles (en secondes)
var bronze_time_threshold: float = 600.0  # 10 minutes
var silver_time_threshold: float = 300.0  # 5 minutes  
var gold_time_threshold: float = 90.0    # 1 minutes 30 seconde
var dev_time_threshold: float = 60.0     # 1 minutes

var is_using_gamepad = false
var medals_displayed = false

func _input(event):
	# Vérifier si l'événement vient d'une manette
	if event is InputEventJoypadMotion or event is InputEventJoypadButton:
		if not is_using_gamepad:
			is_using_gamepad = true
			_enable_buttons_focus(true)
	# Si une autre entrée (clavier/souris) est détectée, désactiver la manette
	elif event is InputEventMouseMotion or event is InputEventMouseButton or event is InputEventKey:
		if is_using_gamepad:
			is_using_gamepad = false
			_enable_buttons_focus(false)
	
	# Si l'utilisateur appuie sur "ok", activer le bouton sélectionné
	if Input.is_action_just_pressed("ok"):
		press_focused_button()

func _enable_buttons_focus(focus: bool):
	# Parcourir tous les descendants de la hiérarchie pour trouver les boutons
	for child in $CanvasLayer.get_children():
		if child is Button:
			if focus:
				child.grab_focus()
			else:
				child.release_focus()

func press_focused_button():
	# Trouver le bouton actuellement sélectionné et simuler un appui
	for child in $CanvasLayer.get_children():
		if child is Button and child.has_focus():
			child.emit_signal("pressed")
			break

func _ready():
	# Masquer toutes les médailles au début (garder seulement les fonds)
	hide_all_medals()
	
	# Attendre un petit délai avant d'afficher les médailles
	await get_tree().create_timer(1.0).timeout
	
	# Déterminer et afficher les médailles gagnées
	await display_earned_medals()

func hide_all_medals():
	# Masquer toutes les médailles principales
	var medal_container = $CanvasLayer/medaille
	if medal_container:
		for child in medal_container.get_children():
			child.visible = false
	
	# Masquer tous les labels de temps des médailles
	var temps_container = $CanvasLayer/temps_medaille
	if temps_container:
		for child in temps_container.get_children():
			child.visible = false
	
	# Cacher le label temps final au début
	var temps_final_label = $CanvasLayer/temps_final
	if temps_final_label:
		temps_final_label.visible = false

func display_earned_medals():
	var player_time = Global.speedrun_time
	
	# Afficher les médailles une par une avec délai
	if player_time <= bronze_time_threshold:
		await show_medal_and_animate("bronze")
		await get_tree().create_timer(0.5).timeout
		
	if player_time <= silver_time_threshold:
		await show_medal_and_animate("argent")
		await get_tree().create_timer(0.5).timeout
		
	if player_time <= gold_time_threshold:
		await show_medal_and_animate("or")
		await get_tree().create_timer(0.5).timeout
		
	if player_time <= dev_time_threshold:
		await show_medal_and_animate("dev")
		await get_tree().create_timer(0.5).timeout
	
	# Afficher les temps requis pour les médailles non obtenues
	display_required_times()
	
	# Attendre un peu puis afficher le temps final
	await get_tree().create_timer(1.0).timeout
	display_final_time()

func show_medal_and_animate(medal_type: String):
	print("Affichage de la médaille: ", medal_type)
	
	# Afficher la médaille principale
	var medal_container = $CanvasLayer/medaille
	if medal_container:
		var medal = medal_container.get_node_or_null("medaille_" + medal_type)
		if medal:
			medal.visible = true
			print("Médaille ", medal_type, " rendue visible")
		else:
			print("Médaille ", medal_type, " non trouvée")
	
	# Jouer l'animation correspondante
	if animation_player:
		if animation_player.has_animation(medal_type):
			print("Lecture de l'animation: ", medal_type)
			animation_player.play(medal_type, 0.5)
			await animation_player.animation_finished
			
			# Jouer le son approprié après l'animation
			if medal_type == "dev":
				var dev_sound = get_node_or_null("dev_medal_sound")
				if dev_sound:
					dev_sound.play()
					print("Son dev_medal_sound joué")
				else:
					print("dev_medal_sound non trouvé")
			else:
				var medal_sound = get_node_or_null("medal_sound")
				if medal_sound:
					medal_sound.play()
					print("Son medal_sound joué")
				else:
					print("medal_sound non trouvé")
		else:
			print("Animation ", medal_type, " non trouvée dans AnimationPlayer")
			# Attendre un délai par défaut si pas d'animation
			await get_tree().create_timer(0.5).timeout
	else:
		print("AnimationPlayer non trouvé")

func display_required_times():
	var player_time = Global.speedrun_time
	print("Affichage des temps requis pour le temps joueur: ", player_time)
	show_required_time("bronze", bronze_time_threshold)
	show_required_time("argent", silver_time_threshold)
	show_required_time("or", gold_time_threshold)
	show_required_time("dev", dev_time_threshold)

func show_required_time(medal_type: String, required_time: float):
	var temps_container = $CanvasLayer/temps_medaille
	if temps_container:
		var temps_label = temps_container.get_node_or_null("temps_" + medal_type)
		if temps_label:
			# Formater le temps requis
			var minutes = int(required_time) / 60
			var seconds = int(required_time) % 60
			var formatted_time = "%d:%02d" % [minutes, seconds]
			
			temps_label.text = "Requis: " + formatted_time
			temps_label.visible = true
			print("Temps requis affiché pour ", medal_type, ": ", temps_label.text)
		else:
			print("Label temps ", medal_type, " non trouvé")

func display_final_time():
	# Récupérer le Label du temps final
	var label = $CanvasLayer/temps_final
	if label:
		# Convertir le temps en minutes, secondes et centièmes
		var total_seconds = Global.speedrun_time
		var minutes = int(total_seconds) / 60
		var seconds = int(total_seconds) % 60
		var centiseconds = int((total_seconds - int(total_seconds)) * 100)
		
		# Formater le temps final
		var formatted_time = "%d:%02d.%02d" % [minutes, seconds, centiseconds]
		
		# Afficher le temps final
		label.text = "Votre temps: " + formatted_time
		label.visible = true
		print("Temps final affiché: ", label.text)
		
		medals_displayed = true
	else:
		print("Label temps_final non trouvé")

func _on_main_menu_pressed():
	print("Bouton Main Menu pressé")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Main_Menu.tscn")
