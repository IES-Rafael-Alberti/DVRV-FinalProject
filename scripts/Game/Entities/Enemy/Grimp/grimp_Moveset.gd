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

@export var MeHitboxOffset: Vector3 = Vector3(80,0,-64)
@export var MeHitboxintMovementDir: Vector3 = Vector3(0,0,0)
@export var MeHitboxAccelerationDir: Vector3 = Vector3(0,0,0)
@export var MeHitboxSize: int = 10
@export var MeHitboxLifetime: float = 0.1

@export var MePlayerMovement: Vector3 = Vector3(300,1,0)
@export var MeStartLagTime: float = 0.2
@export var MeDebounceTime: float = 0.2
@export var MeAnim: Array[String] = ["AtkSLag", "Atk"]
@export var MeResetTime: float = 1.0
var HANumber: int = 0

func _initialized():
	playerModule = get_parent().PlayerModule

################################################################################
#####                             Functions                                #####
################################################################################

func lightAttack():
	if 1 <= HANumber: return
	
	var lookDir = playerModule.StatusModule.lookDir
	
	playerModule.StatusModule.applyDebounce(MeDebounceTime + MeStartLagTime)
	playerModule.AnimModule.forceAnim(MeAnim[0])
	await get_tree().create_timer(MeStartLagTime).timeout
	if playerModule.StatusModule.isStunned: return
	playerModule.AnimModule.forceAnim(MeAnim[1])
	
	playerModule.MovementModule.applyForceV3(MePlayerMovement*Vector3(lookDir,1,1))
	
	movesetUtils.spawnHitbox(lookDir, MeHitboxOffset, MeHitboxintMovementDir, MeHitboxAccelerationDir, MeHitboxSize, MeHitboxLifetime, MeDamage, MeStuntime, MeKnockback)
	
	HANumber += 1
	var befAtkN = HANumber
	await get_tree().create_timer(MeDebounceTime).timeout
	if !playerModule.StatusModule.isStunned:
		playerModule.AnimModule.resetAnim()
	
	await get_tree().create_timer(MeResetTime).timeout
	if befAtkN == HANumber:
		HANumber = 0
