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
@export var distKeep: Vector2 = Vector2(300,100)
@export var distKeepSize: Vector2 = Vector2(50,20)

var targetOffset: Vector2 = Vector2.ZERO

@export_category("Mode 2 = Attack")
@export var atkDistKeep: Vector2 = Vector2(150,30)
@export var waitUntilAttack: float = 1

func _ready():
	await get_tree().create_timer(0.2).timeout
	while true:
		if isBusy:
			await get_tree().process_frame
			continue
		#behavior = 1
		behavior = randi_range(1, 2) if behavior == 0 else randi_range(0, 2)
		
		if behavior == 1:
			targetOffset = Vector2(randi_range(-50,200),randi_range(-200,200))
		
		await get_tree().create_timer(randf_range(waitTimeRange.x,waitTimeRange.y)).timeout
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _AIProcess(delta):
	playerModule.InputModule.movement = Vector2.ZERO
	var closest = AIUtils.findClosestTarget()
	if closest:
		var posDist = abs(closest.position - this.position) 
		match behavior:
			0:
				pass
			1:
				var distOffset = distKeep + targetOffset
				if posDist.x > distOffset.x or posDist.y > distOffset.y:
					AIUtils.moveToPlayer(closest, targetOffset)
				elif posDist.x < distOffset.x-distKeepSize.x and posDist.y < distOffset.y-distKeepSize.y:
					if posDist.x < atkDistKeep.x and posDist.y < atkDistKeep.y:
						AIUtils.lookPlayer(closest)
						AIUtils.useLightAttack()
					else:
						AIUtils.moveFromPlayer(closest)
			2:
				
				if posDist.x > atkDistKeep.x or posDist.y > atkDistKeep.y:
					AIUtils.moveToPlayer(closest)
				else:
					await get_tree().create_timer(waitUntilAttack).timeout
					if posDist.x < atkDistKeep.x and posDist.y < atkDistKeep.y:
						AIUtils.lookPlayer(closest)
						AIUtils.useLightAttack()
	pass
