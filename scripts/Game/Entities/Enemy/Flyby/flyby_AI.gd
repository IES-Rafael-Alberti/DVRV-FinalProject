extends Node

@export_category("General")
@export var waitTimeRange: Vector2 = Vector2(1,3)

@onready var this: Node = get_parent()
@onready var playerModule: Node = this.get_node("PlayerModule")
@onready var AIUtils: Node = get_node("AIUtils")

var isBusy: bool = false
var targets: Array[CharacterBody2D] = []
var behavior: int = 0

@export_category("Mode 1 = Move Towards")
@export var distKeep: Vector2 = Vector2(300,0)
@export var offsetMin: Vector2 = Vector2(-200,-100)
@export var offsetMax: Vector2 = Vector2(200,100)
var targetOffset: Vector2 = Vector2.ZERO

@export_category("Mode 2 = KickAttack")
@export var atkDistKeep: Vector2 = Vector2(150,30)
@export var waitUntilAttack: float = 1
@export var atkChance: Vector2 = Vector2(1,20)

func _ready():
	await get_tree().create_timer(0.2).timeout
	while true:
		if isBusy:
			await get_tree().process_frame
			continue
		behavior = 2
		#behavior = randi_range(1, 2)
		targetOffset = Vector2(randi_range(offsetMin.x,offsetMax.x),randi_range(offsetMin.y,offsetMax.y))
		await get_tree().create_timer(randf_range(waitTimeRange.x,waitTimeRange.y)).timeout
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _AIProcess(delta):
	playerModule.InputModule.movement = Vector2.ZERO
	
	var closest = AIUtils.findClosestTarget(this.get_node("EnemiesDetector").enemies)
	if closest:
		var posDist = abs(closest.position - this.position) 
	
		var distOffset = distKeep + targetOffset
		var velocity = this.velocity
		var speed = playerModule.StatsModule.speed
		match behavior:
			1:
				if abs(velocity.x) < abs(speed.x) or (posDist.x > distOffset.x):
					AIUtils.moveToPlayerX(closest, targetOffset)
				if abs(velocity.y) < abs(speed.y) or posDist.y > distOffset.y:
					AIUtils.moveToPlayerY(closest, targetOffset)
			2:
				if posDist.x < atkDistKeep.x and posDist.y < atkDistKeep.y and atkChance.x == randi_range(0, atkChance.y):
					AIUtils.lookPlayer(closest)
					AIUtils.useLightAttack()
				if abs(velocity.x) < abs(speed.x) or (posDist.x > distOffset.x):
					AIUtils.moveToPlayerX(closest, targetOffset)
				if abs(velocity.y) < abs(speed.y) or posDist.y > distOffset.y:
					AIUtils.moveToPlayerY(closest, targetOffset)
	pass
