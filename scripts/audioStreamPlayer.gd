extends AudioStreamPlayer

var menuMusic = preload("res://assets/Music/menu/nastelbom-epic-485879.mp3")
var nivel1Music = preload("res://assets/music/nivel1/nojisuma-workout-10823.mp3")
var pelea = preload("res://assets/music/pelea boss/aberrantrealities-waitsignal-514236.mp3")

const volNormal = -10.0

func _ready():
	bus = "Music"
	volume_db = volNormal

func play_menu():
	if stream == menuMusic and playing:
		return
	_fade_to(menuMusic)

func play_game():
	if stream == nivel1Music and playing:
		return
	_fade_to(nivel1Music)

func _fade_to(new_music: AudioStream):
	if playing:
		var tween_out = create_tween()
		tween_out.tween_property(self, "volume_db", -90, 1.0)
		await tween_out.finished
		stop()

	#pa cambiar musiquita
	stream = new_music
	volume_db = -90
	play()

	var tween_in = create_tween()
	tween_in.tween_property(self, "volume_db", volNormal, 1.5)
