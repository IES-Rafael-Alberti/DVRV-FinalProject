extends Node

@export var hitboxPacked: PackedScene
@onready var player: Node = get_parent()
@onready var playerModule: Node = get_parent().PlayerModule
@onready var movesetUtils: Node = $MovesetUtils

@export var intMovementDir: Vector3
@export var AccelerationDir: Vector3

@export_category("Melee")
@export var MeDamage: int = 10
@export var MeKnockback: Vector3 = Vector3(500,10,0)
@export var MeStuntime: float = 0.5

@export var MeHitboxOffset: Vector3 = Vector3(80,0,-32)
@export var MeHitboxintMovementDir: Vector3 = Vector3(0,0,0)
@export var MeHitboxAccelerationDir: Vector3 = Vector3(0,0,0)
@export var MeHitboxSize: int = 7
@export var MeHitboxLifetime: float = 0.1

@export var MePlayerMovement: Vector3 = Vector3(300,1,0)
@export var MeStartLagTime: float = 0.5
@export var MeDebounceTime: float = 0.2
@export var MeAnim: Array[String] = ["AtkSLag", "Atk"]
@export var MeResetTime: float = 1.0
var MeNumber: int = 0

@export_category("Grapple")
@export var GrDamage: int = 0
@export var GrKnockback: Vector3 = Vector3(0,0,0)
@export var GrStuntime: float = 0.3

@export var GrHitboxOffset: Vector3 = Vector3(40,0,-64)
@export var GrHitboxintMovementDir: Vector3 = Vector3(0,0,0)
@export var GrHitboxAccelerationDir: Vector3 = Vector3(0,0,0)
@export var GrHitboxSize: int = 5
@export var GrHitboxLifetime: float = 0.2

@export var GrPlayerMovement: Vector3 = Vector3(1000,10,0)
@export var GrStartLagTime: float = 0.5
@export var GrDebounceTime: float = 0.2
@export var GrEndlagTime: float = 0.3
@export var GrAnim: Array[String] = ["GrappleSLag", "Grapple", "GrappleFail"]
@export var GrResetTime: float = 1.0
var GrNumber: int = 0
var GrHasHit: bool = false

@export_category("GrappleHit")
@export var GrHitDamage: int = 10
@export var GrHitKnockback: Vector3 = Vector3(500,10,0)
@export var GrHitStuntime: float = 0.5

@export var GrHitHitboxOffset: Vector3 = Vector3(80,0,-64)
@export var GrHitHitboxintMovementDir: Vector3 = Vector3(0,0,0)
@export var GrHitHitboxAccelerationDir: Vector3 = Vector3(0,0,0)
@export var GrHitHitboxSize: int = 5
@export var GrHitHitboxLifetime: float = 0.1

@export var GrHitPlayerMovement: Vector3 = Vector3(0,0,0)
@export var GrHitStartLagTime: float = 0.2
@export var GrHitDebounceTime: float = 0.2
@export var GrHitAnim: Array[String] = ["GrappleHitSLag", "GrappleHit"]
@export var GrHitResetTime: float = 1.0
var GrHitNumber: int = 0

func _initialized():
	playerModule = get_parent().PlayerModule

################################################################################
#####                             Functions                                #####
################################################################################

func lightAttack():
	if 1 <= MeNumber: return
	
	var lookDir = playerModule.StatusModule.lookDir
	
	playerModule.StatusModule.applyDebounce(MeDebounceTime + MeStartLagTime)
	playerModule.AnimModule.forceAnim(MeAnim[0])
	await get_tree().create_timer(MeStartLagTime).timeout
	if playerModule.StatusModule.isStunned: return
	playerModule.AnimModule.forceAnim(MeAnim[1])
	
	playerModule.MovementModule.applyForceV3(MePlayerMovement*Vector3(lookDir,1,1))
	
	movesetUtils.spawnHitbox(lookDir, MeHitboxOffset, MeHitboxintMovementDir, MeHitboxAccelerationDir, MeHitboxSize, MeHitboxLifetime, MeDamage, MeStuntime, MeKnockback)
	
	MeNumber += 1
	var befAtkN = MeNumber
	await get_tree().create_timer(MeDebounceTime).timeout
	if !playerModule.StatusModule.isStunned:
		playerModule.AnimModule.resetAnim()
	
	await get_tree().create_timer(MeResetTime).timeout
	if befAtkN == MeNumber:
		MeNumber = 0

func heavyAttack():
	if 1 <= GrNumber: return
	GrHasHit = false
	
	var lookDir = playerModule.StatusModule.lookDir
	
	playerModule.StatusModule.applyDebounce(GrDebounceTime + GrStartLagTime)
	playerModule.AnimModule.forceAnim(GrAnim[0])
	await get_tree().create_timer(GrStartLagTime).timeout
	if playerModule.StatusModule.isStunned: return
	playerModule.AnimModule.forceAnim(GrAnim[1])
	
	playerModule.MovementModule.applyForceV3(GrPlayerMovement*Vector3(lookDir,1,1))
	
	var hitbox = movesetUtils.spawnHitbox(lookDir, GrHitboxOffset, GrHitboxintMovementDir, GrHitboxAccelerationDir, GrHitboxSize, GrHitboxLifetime, GrDamage, GrStuntime, GrKnockback)
	hitbox.hit.connect(heavyOnHitAttack)
	
	GrNumber += 1
	var befAtkN = GrNumber
	await get_tree().create_timer(GrDebounceTime).timeout
	if !GrHasHit:
		if !playerModule.StatusModule.isStunned:
			playerModule.AnimModule.forceAnim(GrAnim[2])
		await get_tree().create_timer(GrEndlagTime).timeout
		if !playerModule.StatusModule.isStunned:
			playerModule.AnimModule.resetAnim()
		
	
	await get_tree().create_timer(GrResetTime).timeout
	if befAtkN == GrNumber:
		GrNumber = 0

################################################################################
#####                           Attack Parts                               #####
################################################################################

func heavyOnHitAttack(ignoreThis: Area2D):
	playerModule.MovementModule.setForceV3(Vector3.ZERO)
	if playerModule.StatusModule.isStunned: return
	GrHasHit = true
	var lookDir = playerModule.StatusModule.lookDir
	
	playerModule.StatusModule.applyDebounce(GrHitDebounceTime + GrHitStartLagTime)
	playerModule.AnimModule.forceAnim(GrHitAnim[0])
	await get_tree().create_timer(GrHitStartLagTime).timeout
	if playerModule.StatusModule.isStunned: return
	playerModule.AnimModule.forceAnim(GrHitAnim[1])
	
	playerModule.MovementModule.applyForceV3(GrHitPlayerMovement*Vector3(lookDir,1,1))
	
	movesetUtils.spawnHitbox(lookDir, GrHitHitboxOffset, GrHitHitboxintMovementDir, GrHitHitboxAccelerationDir, GrHitHitboxSize, GrHitHitboxLifetime, GrHitDamage, GrHitStuntime, GrHitKnockback)
	
	GrHitNumber += 1
	var befAtkN = GrHitNumber
	await get_tree().create_timer(GrHitDebounceTime).timeout
	if !playerModule.StatusModule.isStunned:
		playerModule.AnimModule.resetAnim()
	
	await get_tree().create_timer(GrHitResetTime).timeout
	if befAtkN == GrHitNumber:
		GrHitNumber = 0
