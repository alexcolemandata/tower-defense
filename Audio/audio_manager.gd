extends Node2D

@export var sounds: Sounds


func play_sfx_at_location(location: Vector2, audio_stream: AudioStreamMP3) -> void:
	var sfx = AudioStreamPlayer2D.new()
	add_child(sfx)
	sfx.position = location
	sfx.stream = audio_stream
	sfx.finished.connect(sfx.queue_free)
	sfx.play()

func play_sfx(audio_stream: AudioStreamMP3) -> void:
	var sfx = AudioStreamPlayer.new()
	add_child(sfx)
	sfx.stream = audio_stream
	sfx.finished.connect(sfx.queue_free)
	sfx.play()
