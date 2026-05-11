extends Node2D

@export_category("General")
@export var FollowPlayer:bool = true
@export var FollowMaxSpeed:float = 20

@onready var players: Array[CharacterBody2D] = []
@onready var center: Marker2D = $CenterArea

@export_category("Followers")
@export var FollowingPlayer: Array[Node2D] = []
@export var FollowingPlayerUI: Array[Control] = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var updatedX = 0
	if FollowPlayer:
		for player in players:
			if player and player.position.x >= center.global_position.x:
				updatedX = player.position.x - center.global_position.x
	if updatedX > FollowMaxSpeed:
		updatedX = FollowMaxSpeed
	if updatedX != 0:
		position.x += updatedX
		updatePos(updatedX, FollowingPlayer)
		updatePos(updatedX, FollowingPlayerUI)

func updatePos(updatedX, Followers):
		await get_tree().process_frame
		for follower in Followers:
			if follower:
				follower.position.x += updatedX
