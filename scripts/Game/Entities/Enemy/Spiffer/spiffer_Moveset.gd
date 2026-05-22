extends Node

@onready var player: Node = get_parent()
@onready var playerModule: Node = get_parent().PlayerModule
@onready var movesetUtils: Node = $MovesetUtils

@export var intMovementDir: Vector3
@export var AccelerationDir: Vector3
	
@export_category("Teleport")
@export var TpOffsetMin: Vector2 = Vector2(-550,50)
@export var TpOffsetMax: Vector2 = Vector2(550,320)

@export var TpStartLagTime: float = 0.2
@export var TPInsideTimeRadius: Vector2 = Vector2(0.5,1.5)
@export var TpDebounceTime: float = 1
@export var TpAnim: Array[String] = ["DigIn", "DigOut"]
@export var TPResetTime: float = 1.0

var tpOffset: Vector2 = Vector2.ZERO
var TpNumber: int = 0

@export_category("Spit Horizonal")
@export var SHProyectile: PackedScene
@export var SHDamage: int = 10
@export var SHKnockback: Vector3 = Vector3(500,10,0)
@export var SHStuntime: float = 0.5

@export var SHHitboxOffset: Vector3 = Vector3(0,10,0)
@export var SHHitboxintMovementDir: Vector3 = Vector3(10,5,0)
@export var SHHitboxAccelerationDir: Vector3 = Vector3(0,-0.15,0)
@export var SHHitboxSize: int = 3
@export var SHHitboxLifetime: float = -1
@export var SHHitboxTargets: float = 1

@export var SHPlayerMovement: Vector3 = Vector3(0,0,0)
@export var SHStartLagTime: float = 0.2
@export var SHDebounceTime: float = 2
@export var SHAnim: Array[String] = ["SpitHorizontalSLag", "SpitHorizontal"]
@export var SHResetTime: float = 0
var SHNumber: int = 0

@export_category("Spit Vertical")
@export var SVProyectile: PackedScene
@export var SVDamage: int = 10
@export var SVKnockback: Vector3 = Vector3(500,10,0)
@export var SVStuntime: float = 0.5

@export var SVHitboxOffset: Vector3 = Vector3(0,10,0)
@export var SVHitboxintMovementDir = Vector3(0,20,0)
@export var SVHitboxAccelerationDir = Vector3(0,-0.5,0)
@export var SVHitboxSize: int = 3
@export var SVHitboxLifetime: float = -1
@export var SVHitboxTargets: float = 1

@export var SVPlayerMovement: Vector3 = Vector3(0,0,0)
@export var SVStartLagTime: float = 0.8
@export var SVDebounceTime: float = 1
@export var SVAnim: Array[String] = ["SpitVerticalSLag", "SpitVertical"]
@export var SVResetTime: float = 0
var SVNumber: int = 0

func _initialized():
	playerModule = get_parent().PlayerModule
	
################################################################################
#####                             Movement                                 #####
################################################################################

func jump():
	if 1 <= TpNumber or playerModule.StatusModule.isStunned: return
	
	TpNumber += 1
	
	playerModule.StatusModule.applyDebounce(TpDebounceTime + TpStartLagTime+1)
	playerModule.AnimModule.forceAnim(TpAnim[0])
	AudioManager.play_sfx("excava") #excavar/entra
	await get_tree().create_timer(TpStartLagTime).timeout
	if playerModule.StatusModule.isStunned:
		TpNumber = 0
		return
	playerModule.StatusModule.setVisible(false)
	playerModule.StatusModule.setCanBeDamaged(false)
	
	await get_tree().create_timer(randf_range(TPInsideTimeRadius.x,TPInsideTimeRadius.y)).timeout
	
	var camera = player.Camera
	tpOffset = Vector2(randi_range(TpOffsetMin.x,TpOffsetMax.x),randi_range(TpOffsetMin.y,TpOffsetMax.y))
	movesetUtils.tpToPosition(camera.position + tpOffset)
	
	var befAtkN = TpNumber
	playerModule.StatusModule.setVisible(true)
	playerModule.StatusModule.setCanBeDamaged(true)
	playerModule.AnimModule.forceAnim(TpAnim[1])
	AudioManager.play_sfx("sale") #sale
	
	await get_tree().create_timer(TpDebounceTime).timeout
	if !playerModule.StatusModule.isStunned:
		playerModule.AnimModule.resetAnim()
		
	await get_tree().create_timer(TPResetTime).timeout
	if befAtkN == TpNumber:
		TpNumber = 0

################################################################################
#####                              Attacks                                 #####
################################################################################

func lightAttack():
	if 1 <= SHNumber: return
	
	var lookDir = playerModule.StatusModule.lookDir
	
	playerModule.StatusModule.applyDebounce(SHDebounceTime + SHStartLagTime)
	playerModule.AnimModule.forceAnim(SHAnim[0])
	
	await get_tree().create_timer(SHStartLagTime).timeout
	if playerModule.StatusModule.isStunned: return
	playerModule.AnimModule.forceAnim(SHAnim[1])
	
	playerModule.MovementModule.applyForceV3(SHPlayerMovement * Vector3(lookDir, 1, 1))
	
	movesetUtils.spawnProyectile(
		SHProyectile,
		lookDir,
		SHHitboxOffset, 
		SHHitboxintMovementDir, 
		SHHitboxAccelerationDir, 
		SHHitboxSize, 
		SHHitboxLifetime, 
		SHDamage, 
		SHStuntime, 
		SHKnockback,
		false,
		false,
		SHHitboxTargets
	)
	
	SHNumber += 1
	var befAtkN = SHNumber
	
	await get_tree().create_timer(SHDebounceTime).timeout
	if !playerModule.StatusModule.isStunned:
		playerModule.AnimModule.resetAnim()
	
	await get_tree().create_timer(SHResetTime).timeout
	if befAtkN == SHNumber:
		SHNumber = 0

func heavyAttack():
	if 1 <= SVNumber: return
	
	var lookDir = playerModule.StatusModule.lookDir
	
	playerModule.StatusModule.applyDebounce(SVDebounceTime + SVStartLagTime)
	playerModule.AnimModule.forceAnim(SVAnim[0])
	await get_tree().create_timer(SVStartLagTime).timeout
	if playerModule.StatusModule.isStunned: return
	playerModule.AnimModule.forceAnim(SVAnim[1])
	AudioManager.play_sfx("escupitajo") #escupitajo?
	
	playerModule.MovementModule.applyForceV3(SVPlayerMovement * Vector3(lookDir, 1, 1))
	
	## Calculates Shoot
	var closest = movesetUtils.findClosestTarget(player.get_node("EnemiesDetector").enemies)
	var frames = movesetUtils.frames_until_zero(0,SVHitboxintMovementDir.y,SVHitboxAccelerationDir.y)
	var distFrame = (closest.global_position - player.global_position)/frames
	
	SVHitboxintMovementDir.x = abs(distFrame.x) # Compensates the invertion of lookDir
	SVHitboxintMovementDir.z = distFrame.y
	
	movesetUtils.spawnProyectile(
		SVProyectile,
		min(1,max(-1,distFrame.x*100)),
		SVHitboxOffset, 
		SVHitboxintMovementDir, 
		SVHitboxAccelerationDir, 
		SVHitboxSize, 
		SVHitboxLifetime, 
		SVDamage, 
		SVStuntime, 
		SVKnockback,
		false,
		false,
		SVHitboxTargets
	)
	
	SVNumber += 1
	var befAtkN = SVNumber
		
	await get_tree().create_timer(SVDebounceTime).timeout
	if !playerModule.StatusModule.isStunned:
		playerModule.AnimModule.resetAnim()
	
	await get_tree().create_timer(SVResetTime).timeout
	if befAtkN == SVNumber:
		SVNumber = 0
	
	AudioManager.play_sfx("splat") #impacta
