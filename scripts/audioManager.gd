extends Node

var sfx = {
	# --- GENERALES ---
	"bloqueo": preload("res://assets/Music/SFX/SFX bloqueo.mp3"),
	"bonus": preload("res://assets/Music/SFX/general/SFX bonus objeto.mp3"), #cuando recoja un objeto
	"derrota": preload("res://assets/Music/SFX/general/SFX derrota.mp3"),
	"victoria": preload("res://assets/Music/SFX/general/SFX victoriaa.mp3"),
	"launched1": preload("res://assets/Music/SFX/general/SFX launched1.mp3"),
	"launched2": preload("res://assets/Music/SFX/general/SFX launched2.mp3"),
	"arbusto": preload("res://assets/Music/SFX/general/SFX mov arbusto.mp3"),
	#botones
	"btn": preload("res://assets/Music/SFX/SFX_botones.mp3"),
	"btnSalir": preload("res://assets/Music/SFX/SFX_btn_salir.mp3"),
	
	# --- JUGADOR ---
	"jump": preload("res://assets/Music/SFX/jugador/SFX salto.mp3"),
	"ataqueBaston": preload("res://assets/Music/SFX/jugador/ataques/SFX ataque baston.mp3"),
	"cabezazo": preload("res://assets/Music/SFX/jugador/ataques/SFX cabezazo.mp3"),
	"magiaLigera": preload("res://assets/Music/SFX/jugador/ataques/SFX-ataque-magico-ligero.mp3"),
	"magiaCargada": preload("res://assets/Music/SFX/jugador/ataques/SFX-ataque-magico-cargado.mp3"),
	"combo1": preload("res://assets/Music/SFX/jugador/ataques/SFX ataqueCombo1.mp3"),
	"combo2": preload("res://assets/Music/SFX/jugador/ataques/SFX ataqueCombo2.mp3"),
	"combo3": preload("res://assets/Music/SFX/jugador/ataques/SFX ataqueCombo3.mp3"),
	
	# --- ENEMIGOS ---
	#general
	"agarre": preload("res://assets/Music/SFX/enemigos/SFX agarre.mp3"),
	"agarreFuerte": preload("res://assets/Music/SFX/enemigos/SFX agarre masFuerte.mp3"),
	"escupitajo": preload("res://assets/Music/SFX/enemigos/SFX escupitajo.mp3"),
	"splat": preload("res://assets/Music/SFX/enemigos/SFX splat.mp3"), #lo que suena despues del impacto del escupitajo
	"sale": preload("res://assets/Music/SFX/enemigos/SFX sale fuera.mp3"), #para el enemigo que sale de la tierra
	"excava": preload("res://assets/Music/SFX/enemigos/SFX excava.mp3"), #para el enmigo que excava
	
	#grimp
	"zarpazoG": preload("res://assets/Music/SFX/enemigos/SFX zarpazo grimp.mp3"),
	
	#mosca
	"mosca": preload("res://assets/Music/SFX/enemigos/SFX sonido mosca.mp3"),
	"ataqueM": preload("res://assets/Music/SFX/enemigos/SFX ataque mosca.mp3"),
	"patada": preload("res://assets/Music/SFX/enemigos/SFX patada.mp3"),
	
	#pumpumf
	"mordisco": preload("res://assets/Music/SFX/enemigos/SFX mordisco.mp3"),
	"zarpazoP": preload("res://assets/Music/SFX/enemigos/SFX zarpazo pumpumf.mp3"),
	"zarpazoPFuerte": preload("res://assets/Music/SFX/enemigos/SFX zarpazo pumpumf masFuerte.mp3"),
	
	#boss
	"ataqueB": preload("res://assets/Music/SFX/enemigos/SFX ataque boss.mp3"),
	"ataqueBFuerte": preload("res://assets/Music/SFX/enemigos/SFX ataque boss masFuerte.mp3"),
	"aterrizaB": preload("res://assets/Music/SFX/enemigos/SFX aterrizaje boss.mp3"),
}

const MAX_PLAYERS = 8
var _players: Array[AudioStreamPlayer] = []

func _ready():
	for i in MAX_PLAYERS:
		var p = AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		_players.append(p)

func play_sfx(name: String, volume_db: float = 0.0):
	if not sfx.has(name):
		push_warning("SFX no encontrado: " + name)
		return
	
	#eto para buscar un player libre
	var player = _get_free_player()
	if player:
		player.stream = sfx[name]
		player.volume_db = volume_db
		player.play()

func _get_free_player() -> AudioStreamPlayer:
	for p in _players:
		if not p.playing:
			return p
	return _players[0]  #si estantodos ocupados, reutilizar el primero
