extends Node

@onready var thisAI: Node = get_parent()
@onready var this: Node = get_parent().get_parent()
@onready var playerModule: Node = this.get_node("PlayerModule")

################################################################################
#####                             Movement                                 #####
################################################################################

func lookPlayer(target: CharacterBody2D):
	if !playerModule.StatusModule.isStunned and target:
		if target.position.x > this.position.x:
			playerModule.StatusModule.setLookDir(1)
		elif target.position.x < this.position.x:
			playerModule.StatusModule.setLookDir(-1)
	
func moveToPlayer(target: CharacterBody2D, offset: Vector2 = Vector2.ZERO):
	var targetPos = target.position + offset
	moveSameHorizontal(targetPos.x)
	moveSameVertical(targetPos.y)
	
func moveToPlayerX(target: CharacterBody2D, offset: Vector2 = Vector2.ZERO):
	var targetPos = target.position + offset
	moveSameHorizontal(targetPos.x)
	
func moveToPlayerY(target: CharacterBody2D, offset: Vector2 = Vector2.ZERO):
	var targetPos = target.position + offset
	moveSameVertical(targetPos.y)
	
func moveFromPlayer(target: CharacterBody2D, offset: Vector2 = Vector2.ZERO):
	var targetPos = 2 * this.position - target.position + offset
	moveSameHorizontal(targetPos.x)
	moveSameVertical(targetPos.y)

func moveSameHorizontal(target: int):
	if target:
		var enemyDir: float = (target - this.position.x)
		if abs(enemyDir) > 100:
			playerModule.InputModule.movement.x= 1 if enemyDir > 0 else -1
	pass
	
func moveSameVertical(target: int):
	if target:
		var enemyDir: float = (target - this.position.y)
		if abs(enemyDir) > 20:
			playerModule.InputModule.movement.y = 1 if enemyDir > 0 else -1
			
	pass
	
################################################################################
#####                              Attacks                                 #####
################################################################################

func useJump():
	if playerModule.InputModule.jumpKey == false:
		playerModule.InputModule.jumpKey = true
		await waitTime(0.1)
		playerModule.InputModule.jumpKey = false
		
func useLightAttack():
	if playerModule.InputModule.lightAttack == false:
		playerModule.InputModule.lightAttack = true
		await waitTime(0.1)
		playerModule.InputModule.lightAttack = false

func useHeavyAttack():
	if playerModule.InputModule.heavyAttack == false:
		playerModule.InputModule.heavyAttack = true
		await waitTime(0.1)
		playerModule.InputModule.heavyAttack = false

################################################################################
#####                              Others                                 #####
################################################################################

func findClosestTarget(targets: Array[CharacterBody2D]):
	var closest: Node2D = null
	var closest_pos := INF
	
	for target in targets:
		if target == null: continue
		
		var dist: float = this.position.distance_squared_to(target.global_position)
		if dist < closest_pos:
			closest_pos = dist
			closest = target
	
	return closest
		

func waitTime(time: float):
	thisAI.isBusy = true
	await get_tree().create_timer(time).timeout
	thisAI.isBusy = false
	
################################################################################
#####                              Signals                                 #####
################################################################################
