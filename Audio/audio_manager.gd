extends Node2D

@export var sounds: Sounds


func play_sound_at_location(
	location: Vector2, 
	sound: SoundSettings,
	volume: float = -1.0
	) -> Node:
	var sfx = AudioStreamPlayer2D.new()
	sfx.position = location
	return play_sound_with_stream_player(sfx, sound, volume)

func play_sound(sound: SoundSettings, volume: float = -1.0) -> Node:
	var sfx = AudioStreamPlayer.new()
	return play_sound_with_stream_player(sfx, sound, volume)

## Play a sound using either an AudioStreamPlayer, or AudioStreamPlayer2D
func play_sound_with_stream_player(stream_player: Node, sound: SoundSettings, volume: float = -1.0) -> Node:
	add_child(stream_player)

	stream_player.stream = sound.stream

	if volume < 0:
		stream_player.volume_linear = sound.default_volume
	else:
		stream_player.volume_linear = volume

	stream_player.finished.connect(stream_player.queue_free)
	stream_player.play()
	return stream_player
