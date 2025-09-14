# MusicManager.gd
extends Node

var audio_player: AudioStreamPlayer
var tween: Tween

func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)

func play_music(music_stream: AudioStream, fade_in_duration: float = 1.0):
	if audio_player.stream == music_stream and audio_player.playing:
		# La même musique joue déjà, on ne fait rien
		return
	
	if music_stream:
		# Assurer que la musique est en boucle
		if music_stream.has_method("set_loop"):
			music_stream.set_loop(true)
		elif music_stream.has_property("loop"):
			music_stream.loop = true
	
	if audio_player.playing:
		# Transition smooth vers la nouvelle musique
		await fade_to_new_music(music_stream, fade_in_duration)
	else:
		# Première fois qu'on joue de la musique
		audio_player.stream = music_stream
		audio_player.volume_db = -80
		audio_player.play()
		fade_in(fade_in_duration)

func fade_to_new_music(new_music: AudioStream, duration: float = 1.0):
	# Fade out la musique actuelle
	await fade_out(duration * 0.5)
	
	# Changer la musique
	audio_player.stream = new_music
	audio_player.volume_db = -80
	audio_player.play()
	
	# Fade in la nouvelle musique
	fade_in(duration * 0.5)

func fade_in(duration: float = 1.0):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(audio_player, "volume_db", 0, duration)

func fade_out(duration: float = 1.0):
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(audio_player, "volume_db", -80, duration)
	await tween.finished

func stop_music(fade_out_duration: float = 1.0):
	if audio_player.playing:
		await fade_out(fade_out_duration)
		audio_player.stop()

func set_volume(volume_db: float):
	audio_player.volume_db = volume_db

func temporary_volume_down(target_volume_db: float = -20, duration: float = 0.5):
	"""Baisse temporairement le volume pendant une transition"""
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(audio_player, "volume_db", target_volume_db, duration)

func restore_volume(duration: float = 0.5):
	"""Restaure le volume normal après une transition"""
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(audio_player, "volume_db", 0, duration)

func is_playing() -> bool:
	return audio_player.playing
