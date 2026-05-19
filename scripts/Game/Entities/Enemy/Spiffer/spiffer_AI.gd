extends Node2D

@export_category("General")
@export var waitTimeRange: Vector2 = Vector2(3,7)

@onready var this: Node = get_parent()
@onready var playerModule: Node = this.get_node("PlayerModule")
@onready var AIUtils: Node = get_node("AIUtils")

var isBusy: bool = false
var behavior: int = 0

@export_category("Mode 1 = Move To Position")
@export var offsetMin: Vector2 = Vector2(-550,50)
@export var offsetMax: Vector2 = Vector2(550,320)

var targetOffset: Vector2 = Vector2.ZERO

@export_category("Mode 2 = Attack")
@export var distanceToHorizontal: Vector2 = Vector2(800,10)
@export var waitUntilAttack: float = 1

func _ready():
	await get_tree().create_timer(0.2).timeout
	while true:
		if isBusy:
			await get_tree().process_frame
			continue
		behavior = 1
		
		await get_tree().create_timer(randf_range(waitTimeRange.x,waitTimeRange.y)).timeout
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _AIProcess(delta):
	playerModule.InputModule.movement = Vector2.ZERO
	var closest = AIUtils.findClosestTarget(this.get_node("EnemiesDetector").enemies)
	AIUtils.lookPlayer(closest)
	if isBusy: return
	isBusy = true
	if closest: 
		match behavior:
			0:
				pass
			1:
				while !playerModule.StatusModule.canMove():
					await get_tree().physics_frame 
				AIUtils.useJump()
				behavior = 2
			2:
				var dist = this.global_position - closest.global_position
				if abs(dist.y) < distanceToHorizontal.y and abs(dist.x) < distanceToHorizontal.x:
					AIUtils.useLightAttack()
				else:
					AIUtils.useHeavyAttack()
			3:
				pass
	isBusy = false
	pass
