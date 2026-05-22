extends Node2D

@export var PackedPlayerGUI: PackedScene
@export var PackedPlayers: Array[PackedScene] = []
@export var SpawnPos: Array[Marker2D] = []

@export_category("OnGameOver")
@export var deathCheckTime: float = 1.5
@export var MenuScreen: PackedScene


@export_category("Debug")
@export var ShowCollisions: bool
@export var ShowHitboxes: bool

@onready var playerFollower: Node2D = $PlayerFollower
@onready var gameGUI: Control = $Ui
@onready var gameCamera: Camera2D = $Camera2D
@onready var mapBoundry: Area2D = $Map/Boundry
@onready var playersGUI: HBoxContainer = gameGUI.get_node("PlayersGUI")
@onready var players: Array[CharacterBody2D] = []

var game_over_shown: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_players()
	start_game()
	MusicManager.play_game()
	_connect_game_over_menu()
	
func _process(delta):
	# Ya no hacemos cambio de escena automático al morir.
	# El menú de Game Over se encarga de eso via player_death.g
	#if $Players.get_child_count() == 0:
		#await get_tree().create_timer(deathCheckTime).timeout
		#if $Players.get_child_count() == 0:
			#get_tree().change_scene_to_packed(MenuScreen)
			pass

func spawn_players():
	var i: int = 0
	for player in PackedPlayers:
		var instance = player.instantiate()
		instance.MovingArea = mapBoundry
		instance.Camera = gameCamera
		instance.position = SpawnPos[i].position
		instance.ShowCollisions = ShowCollisions
		instance.ShowHitboxes = ShowHitboxes
		players.append(instance)
		$Players.add_child(instance)
		spawnPlayerGUI(instance) 
		_connect_player_death(instance)
		i += 1

func start_game():
	playerFollower.FollowPlayer = true
	playerFollower.players = players
	
################################################################################
#####                           Game Over                                  #####
################################################################################

func _connect_game_over_menu():
	var game_over_node = gameGUI.get_node_or_null("GameOver")
	if game_over_node:
		game_over_node.retry_pressed.connect(_on_game_over_retry)
		game_over_node.exit_pressed.connect(_on_game_over_exit)

func _connect_player_death(player_instance: CharacterBody2D):
	# Busca el nodo PlayerDeath (si existe) y conecta su señal
	var death_node = player_instance.get_node_or_null("PlayerDeath")
	if death_node and death_node.has_signal("player_died"):
		death_node.player_died.connect(_on_player_died)
		
func _on_player_died():
	if game_over_shown:
		return
	game_over_shown = true
	var game_over_node = gameGUI.get_node_or_null("GameOver")
	if game_over_node:
		game_over_node.show_game_over()
		
func _on_game_over_retry():
	game_over_shown = false
	get_tree().paused = false
	get_tree().call_deferred("reload_current_scene")

func _on_game_over_exit():
	game_over_shown = false
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_packed", MenuScreen)

################################################################################
#####                              Utility                                 #####
################################################################################

func spawnPlayerGUI(player: CharacterBody2D):
	var instance = PackedPlayerGUI.instantiate()
	instance.playerStats = player.get_node("PlayerModule/StatsModule")
	playersGUI.add_child(instance)
