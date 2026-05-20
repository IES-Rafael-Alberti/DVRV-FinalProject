extends Node

@onready var player: Node = get_parent()
@onready var playerModule: Node = get_parent().PlayerModule
@onready var movesetUtils: Node = $MovesetUtils

@export var intMovementDir: Vector3
@export var AccelerationDir: Vector3

@export_category("LightAttack")
@export var LADamage: Array[int] = [10,10,10]
@export var LAKnockback: Array[Vector3] = [Vector3(50,5,0),Vector3(50,5,0),Vector3(800,15,0)]
@export var LAAnim: Array[String] = ["AtkLight1","AtkLight2","AtkLight3"]
@export var LAStuntime: Array[float] = [0.3,0.3,1]

@export var LAHitboxOffset: Array[Vector3] = [Vector3(80,64,0),Vector3(80,64,0),Vector3(80,64,0)]
@export var LAHitboxintMovementDir: Array[Vector3] = [Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0)]
@export var LAHitboxAccelerationDir: Array[Vector3] = [Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0)]
@export var LAHitboxSize: Array[int] = [10,10,10]
@export var LAHitboxLifetime: Array[float] = [0.1,0.1,0.1]

@export var LAPlayerMovement: Array[Vector3] = [Vector3(200,1,0),Vector3(200,1,0),Vector3(200,1,0)]
@export var LAStartLagTime: Array[float] = [0,0,0]
@export var LADebounceTime: Array[float] = [0.2,0.2,0.2]
@export var LAResetTime: Array[float] = [1.0,1.0,2.0]
var LANumber: int = 0

@export_category("Heavy")
@export var HADamage: int = 40
@export var HAKnockback: Vector3 = Vector3(500,-1,0)
@export var HAStuntime: float = 1

@export var HAHitboxOffset: Vector3 = Vector3(80,40,0)
@export var HAHitboxintMovementDir: Vector3 = Vector3(0,0,0)
@export var HAHitboxAccelerationDir: Vector3 = Vector3(0,0,0)
@export var HAHitboxSize: int = 10
@export var HAHitboxLifetime: float = 0.1

@export var HAPlayerMovement: Vector3 = Vector3(300,1,0)
@export var HAStartLagTime: float = 0.1
@export var HADebounceTime: float = 0.2
@export var HAAnim: Array[String] = ["AtkSLagHeavy", "AtkHeavy"]
@export var HAResetTime: float = 1.0
var HANumber: int = 0

@export_category("Air")
@export var AirDamage: int = 30
@export var AirKnockback: Vector3 = Vector3(700,10,0)
@export var AirStuntime: float = 1

@export var AirHitboxOffset: Vector3 = Vector3(60,-30,-64)
@export var AirHitboxintMovementDir: Vector3 = Vector3(0,0,0)
@export var AirHitboxAccelerationDir: Vector3 = Vector3(0,0,0)
@export var AirHitboxSize: int = 11
@export var AirHitboxLifetime: float = 0.2

@export var AirPlayerMovement: Vector3 = Vector3(0,0,0)
@export var AirStartLagTime: float = 0
@export var AirDebounceTime: float = 0.2
@export var AirAnim: Array[String] = ["AtkLight1"]
@export var AirResetTime: float = 0.5

@export var AirHitPlayerMovement: Vector3 = Vector3(0,10,0)
@export var AirHitMaxTriggerAmount: int = 1
var AirNumber: int = 0
var AirHitNumber: int = 0

@export_category("Light Magic")
@export var LMProyectile: PackedScene
@export var LMManaCost: float = 10
@export var LMDamage: int = 10
@export var LMKnockback: Vector3 = Vector3(100,5,0)
@export var LMStuntime: float = 0.2

@export var LMHitboxOffset: Vector3 = Vector3(100,30,0)
@export var LMHitboxintMovementDir: Vector3 = Vector3(10,0,0)
@export var LMHitboxAccelerationDir: Vector3 = Vector3(0,0,0)
@export var LMHitboxSize: int = 3
@export var LMHitboxLifetime: float = 1
@export var LMHitboxTargets: float = 1

@export var LMPlayerMovement: Vector3 = Vector3(0,0,0)
@export var LMDebounceTime: float = 0.7
@export var LMAnim: Array[String] = ["MagicLight"]
@export var LMResetTime: float = 0
var LMNumber: int = 0

func _initialized():
	playerModule = get_parent().PlayerModule

################################################################################
#####                             Movement                                 #####
################################################################################

func jump():
	movesetUtils.defaultJump()

################################################################################
#####                              Attacks                                 #####
################################################################################

func lightAttack():
	if LADamage.size() <= LANumber: return
	
	var lookDir = playerModule.StatusModule.lookDir
	
	playerModule.StatusModule.applyDebounce(LADebounceTime[LANumber] + LAStartLagTime[LANumber])
	playerModule.AnimModule.forceAnim(LAAnim[LANumber])
	await get_tree().create_timer(LAStartLagTime[LANumber]).timeout
	if playerModule.StatusModule.isStunned: return
	
	playerModule.MovementModule.applyForceV3(LAPlayerMovement[LANumber]*Vector3(lookDir,1,1))
	var hitbox = movesetUtils.spawnHitbox(
		lookDir, 
		LAHitboxOffset[LANumber], 
		LAHitboxintMovementDir[LANumber], 
		LAHitboxAccelerationDir[LANumber], 
		LAHitboxSize[LANumber], 
		LAHitboxLifetime[LANumber], 
		LADamage[LANumber], 
		LAStuntime[LANumber], 
		LAKnockback[LANumber]
	)
	hitbox.hit.connect(movesetUtils.regenMagicHit)
	
	LANumber += 1
	var befAtkN = LANumber
	await get_tree().create_timer(LADebounceTime[LANumber-1]).timeout
	if !playerModule.StatusModule.isStunned:
		playerModule.AnimModule.resetAnim()
	
	await get_tree().create_timer(LAResetTime[LANumber-1]).timeout
	if befAtkN == LANumber:
		LANumber = 0

func heavyAttack():
	if 1 <= HANumber: return
	
	var lookDir = playerModule.StatusModule.lookDir
	# StartLag
	playerModule.StatusModule.applyDebounce(HADebounceTime + HAStartLagTime)
	playerModule.AnimModule.forceAnim(HAAnim[0])
	await get_tree().create_timer(HAStartLagTime).timeout
	# Mid Attack
	if playerModule.StatusModule.isStunned: return
	playerModule.AnimModule.forceAnim(HAAnim[1])
	
	playerModule.MovementModule.applyForceV3(HAPlayerMovement*Vector3(lookDir,1,1))
	
	var hitbox = movesetUtils.spawnHitbox(
		lookDir, 
		HAHitboxOffset,
		HAHitboxintMovementDir, 
		HAHitboxAccelerationDir,
		HAHitboxSize,
		HAHitboxLifetime, 
		HADamage, 
		HAStuntime, 
		HAKnockback
	)
	hitbox.hit.connect(movesetUtils.regenMagicHit)
	
	HANumber += 1
	var befAtkN = HANumber
	# Endlag
	await get_tree().create_timer(HADebounceTime).timeout
	if !playerModule.StatusModule.isStunned:
		playerModule.AnimModule.resetAnim()
	
	await get_tree().create_timer(HAResetTime).timeout
	if befAtkN == HANumber:
		HANumber = 0

func airAttack():
	if 1 <= AirNumber: return

	var lookDir = playerModule.StatusModule.lookDir
	# StartLag
	playerModule.StatusModule.applyDebounce(AirDebounceTime + AirStartLagTime)
	playerModule.AnimModule.forceAnim(AirAnim[0])
	await get_tree().create_timer(AirStartLagTime).timeout

	# Mid Attack
	if playerModule.StatusModule.isStunned: return

	playerModule.MovementModule.applyForceV3(AirPlayerMovement * Vector3(lookDir,1,1))

	var hitbox = movesetUtils.spawnHitbox(
		lookDir, 
		AirHitboxOffset, 
		AirHitboxintMovementDir, 
		AirHitboxAccelerationDir, 
		AirHitboxSize, 
		AirHitboxLifetime, 
		AirDamage, 
		AirStuntime, 
		AirKnockback
	)
	hitbox.hit.connect(airAttackHit)
	hitbox.hit.connect(movesetUtils.regenMagicHit)
	
	AirNumber += 1
	var befAtkN = AirNumber

	# Endlag
	await get_tree().create_timer(AirDebounceTime).timeout
	if !playerModule.StatusModule.isStunned:
		playerModule.AnimModule.resetAnim()

	await get_tree().create_timer(AirResetTime).timeout
	if befAtkN == AirNumber:
		AirNumber = 0
		AirHitNumber = 0
	
func airAttackHit(hitbox: Area2D):
	if AirHitNumber >= AirHitMaxTriggerAmount: return
	var lookDir = playerModule.StatusModule.lookDir
	playerModule.MovementModule.applyForceV3(AirHitPlayerMovement * Vector3(lookDir,1,1))
	AirHitNumber += 1

func lightMagic():
	if 1 <= LMNumber: return
	if not movesetUtils.useMana(LMManaCost): return
	
	var lookDir = playerModule.StatusModule.lookDir
	
	playerModule.StatusModule.applyDebounce(LMDebounceTime)
	if playerModule.StatusModule.isStunned: return
	playerModule.AnimModule.forceAnim(LMAnim[0])
	
	playerModule.MovementModule.applyForceV3(LMPlayerMovement * Vector3(lookDir, 1, 1))
	
	movesetUtils.spawnProyectile(
		LMProyectile,
		lookDir,
		LMHitboxOffset, 
		LMHitboxintMovementDir, 
		LMHitboxAccelerationDir, 
		LMHitboxSize, 
		LMHitboxLifetime, 
		LMDamage, 
		LMStuntime, 
		LMKnockback,
		false,
		false,
		LMHitboxTargets
	)
	
	LMNumber += 1
	var befAtkN = LMNumber
	await get_tree().create_timer(LMDebounceTime).timeout
	if !playerModule.StatusModule.isStunned:
		playerModule.AnimModule.resetAnim()
	
	await get_tree().create_timer(LMResetTime).timeout
	if befAtkN == LMNumber:
		LMNumber = 0
