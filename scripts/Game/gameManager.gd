extends Node2D

@export var PackedPlayerGUI: PackedScene
@export var PackedPlayers: Array[PackedScene] = []
@export var SpawnPos: Array[Marker2D] = []

@export_category("Debug")
@export var ShowCollisions: bool
@export var ShowHitboxes: bool

@onready var playerFollower: Node2D = $PlayerFollower
@onready var gameGUI: Control = $Ui
@onready var gameCamera: Camera2D = $Camera2D
@onready var mapBoundry: Area2D = $Map/Boundry
@onready var playersGUI: HBoxContainer = gameGUI.get_node("PlayersGUI")
@onready var players: Array[CharacterBody2D] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_players()
	start_game()

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
		i += 1

func start_game():
	playerFollower.FollowPlayer = true
	playerFollower.players = players

################################################################################
#####                              Utility                                 #####
################################################################################

func spawnPlayerGUI(player: CharacterBody2D):
	var instance = PackedPlayerGUI.instantiate()
	instance.playerStats = player.get_node("PlayerModule/StatsModule")
	playersGUI.add_child(instance)
