extends Node

@export_category("General")
@export var waitTimeRange: Vector2 = Vector2(1,3)

@onready var this: Node = get_parent()
@onready var playerModule: Node = this.get_node("PlayerModule")

var isBusy: bool = false
var targets: Array[CharacterBody2D] = []
var behavior: int = 0

@export_category("Mode 1 = Move Towards")
@export var distKeep: Vector2 = Vector2(300,100)
@export var distKeepSize: Vector2 = Vector2(50,20)

var targetOffset: Vector2 = Vector2.ZERO

@export_category("Mode 2 = Attack")
@export var atkDistKeep: Vector2 = Vector2(150,20)
@export var waitUntilAttack: float = 1
# 0 - Nothing
# 1 - Move closer
# 1 - Attack

func _ready():
	await get_tree().create_timer(0.2).timeout
	while true:
		if isBusy:
			await get_tree().process_frame
			continue
		#behavior = 0
		behavior = randi_range(1, 2) if behavior == 0 else randi_range(0, 2)
		if behavior == 1:
			targetOffset = Vector2(randi_range(-50,200),randi_range(-200,200))
		await get_tree().create_timer(randf_range(waitTimeRange.x,waitTimeRange.y)).timeout
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	playerModule.InputModule.movement = Vector2.ZERO
	var closest = findClosestTarget()
	if closest:
		var posDist = abs(closest.position - this.position) 
		match behavior:
			0:
				moveToPlayer(closest, targetOffset)
			1:
				var distOffset = distKeep + targetOffset
				if posDist.x > distOffset.x or posDist.y > distOffset.y:
					moveToPlayer(closest, targetOffset)
				elif posDist.x < distOffset.x-distKeepSize.x and posDist.y < distOffset.y-distKeepSize.y:
					moveFromPlayer(closest)
			2:
				
				if posDist.x > atkDistKeep.x or posDist.y > atkDistKeep.y:
					moveToPlayer(closest)
				else:
					await get_tree().create_timer(waitUntilAttack).timeout
					if posDist.x < atkDistKeep.x and posDist.y < atkDistKeep.y:
						moveToPlayer(closest)
						if randi_range(0, 1) == 1:
							useLightAttack()
						else:
							useHeavyAttack()
	pass
	
	
################################################################################
#####                              Utility                                 #####
################################################################################

func moveToPlayer(target: CharacterBody2D, offset: Vector2 = Vector2.ZERO):
	var targetPos = target.position + offset
	moveSameHorizontal(targetPos.x)
	moveSameHeight(targetPos.y)
	
func moveFromPlayer(target: CharacterBody2D, offset: Vector2 = Vector2.ZERO):
	var targetPos = 2 * this.position - (target.position + offset)
	moveSameHorizontal(targetPos.x)
	moveSameHeight(targetPos.y)

func moveSameHorizontal(target: int):
	if target:
		var enemyDir: float = (target - this.position.x)
		if abs(enemyDir) > 100:
			playerModule.InputModule.movement.x= 1 if enemyDir > 0 else -1
	pass
	
func moveSameHeight(target: int):
	if target:
		var enemyDir: float = (target - this.position.y)
		if abs(enemyDir) > 20:
			playerModule.InputModule.movement.y = 1 if enemyDir > 0 else -1
	pass

func findClosestTarget():
	var closest: Node2D = null
	var closest_pos := INF
	
	for target in targets:
		if target == null: continue
		
		var dist: float = this.position.distance_squared_to(target.global_position)
		if dist < closest_pos:
			closest_pos = dist
			closest = target
	
	return closest
		

################################################################################
#####                              Attacks                                 #####
################################################################################

func useLightAttack():
	if playerModule.InputModule.lightAttack == false:
		playerModule.InputModule.lightAttack = true
		isBusy = true
		await get_tree().create_timer(1.0).timeout
		playerModule.InputModule.lightAttack = false
		isBusy = false

func useHeavyAttack():
	if playerModule.InputModule.heavyAttack == false:
		playerModule.InputModule.heavyAttack = true
		isBusy = true
		await get_tree().create_timer(1.0).timeout
		playerModule.InputModule.heavyAttack = false
		isBusy = false

################################################################################
#####                              Signals                                 #####
################################################################################

func _on_ai_range_body_entered(body):
	if body.is_in_group("Player"):
		targets.append(body)

func _on_ai_range_body_exited(body):
	if body.is_in_group("Player"):
		targets.erase(body)
