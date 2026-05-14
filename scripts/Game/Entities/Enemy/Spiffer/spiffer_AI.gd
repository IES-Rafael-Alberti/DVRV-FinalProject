extends Node2D

@export_category("General")
@export var waitTimeRange: Vector2 = Vector2(1,3)

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
@export var atkDistKeep: Vector2 = Vector2(150,30)
@export var waitUntilAttack: float = 1

func _ready():
	await get_tree().create_timer(0.2).timeout
	while true:
		if isBusy:
			await get_tree().process_frame
			continue
		behavior = 1
		#behavior = randi_range(1, 2) if behavior == 0 else randi_range(0, 2)
		
		await get_tree().create_timer(randf_range(waitTimeRange.x,waitTimeRange.y)).timeout
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _AIProcess(delta):
	playerModule.InputModule.movement = Vector2.ZERO
	var closest = AIUtils.findClosestTarget(this.get_node("EnemiesDetector").enemies)
	AIUtils.lookPlayer(closest)
	if closest:
		var posDist = abs(closest.position - this.position) 
		match behavior:
			0:
				pass
			1:
				AIUtils.useJump()
				behavior = 2
			2:
				AIUtils.useHeavyAttack()
				#AIUtils.useLightAttack()
	pass
