extends Node

@export_category("General")
@export var waitTimeRange: Vector2 = Vector2(1,2)

@onready var this: Node = get_parent()
@onready var playerModule: Node = this.get_node("PlayerModule")
@onready var AIUtils: Node = get_node("AIUtils")

var isBusy: bool = false
var targets: Array[CharacterBody2D] = []
var behavior: int = 0


@export_category("Mode -1 = Move Away")
@export var runDistKeep: Vector2 = Vector2(400,100)


@export_category("Mode 1 = Attack")
@export var atkDistKeep: Vector2 = Vector2(150,30)
@export var atkEndlagWait: Vector2 = Vector2(1.0,3.0)

@export_category("Mode 2 = Grapple")
@export var grapDistKeep: Vector2 = Vector2(400,30)
@export var grapEndlagWait: Vector2 = Vector2(1.0,3.0)

func _ready():
	await get_tree().create_timer(0.2).timeout
	while true:
		if isBusy:
			await get_tree().process_frame
			continue
		#behavior = 2
		behavior = randi_range(1, 2)
		
		await get_tree().create_timer(randf_range(waitTimeRange.x,waitTimeRange.y)).timeout
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _AIProcess(delta):
	if isBusy: return
	playerModule.InputModule.movement = Vector2.ZERO
	var closest = AIUtils.findClosestTarget()
	if closest:
		var posDist = abs(closest.position - this.position) 
		match behavior:
			1:
				if posDist.x > atkDistKeep.x or posDist.y > atkDistKeep.y:
					AIUtils.moveToPlayer(closest)
				else:
					AIUtils.lookPlayer(closest)
					await AIUtils.useLightAttack()
					AIUtils.waitTime(randf_range(atkEndlagWait.x,atkEndlagWait.y))
			2:
				if posDist.x > grapDistKeep.x or posDist.y > grapDistKeep.y:
					AIUtils.moveToPlayer(closest)
				else:
					AIUtils.lookPlayer(closest)
					await AIUtils.useHeavyAttack()
					AIUtils.waitTime(randf_range(grapEndlagWait.x,grapEndlagWait.y))
