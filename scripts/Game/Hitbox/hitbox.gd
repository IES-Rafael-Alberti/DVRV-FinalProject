extends Area2D

signal initialized()
signal hit(this: Node2D)


@export_category("Movement Values")
@export var intMovementDir: Vector3
@export var AccelerationDir: Vector3

@export_category("Hitbox Values")
@export var damage: int
@export var height: int
@export var stuntime: float
@export var knockback: Vector3
@export var targetsAmount: int = 500
@export var friendGroups: Array[StringName]
@export var followHeight: bool

@export_category("LIfeTime Values")
@export var lifeTime: float = -1

var showHitbox: bool = false

func _ready():
	$HitboxMovementModule.intMovementDir = intMovementDir
	$HitboxMovementModule.AccelerationDir = AccelerationDir
	$HitboxSprite.visible = showHitbox
	$ImaginaryHitboxShower.visible = showHitbox
	$HitboxModule.damage = damage
	$HitboxModule.height = height
	$HitboxModule.stuntime = stuntime
	$HitboxModule.knockback = knockback
	$HitboxModule.targetsAmount = targetsAmount
	$HitboxModule.friendGroups = friendGroups
	$HitboxModule.callOnHit = "sendHitSignal"
	$HitboxModule.followHeight = followHeight
	$LifetimeModule.lifeTime = lifeTime
	initialized.emit()
	
	if !showHitbox:
		$ImaginaryHitboxShower.queue_free()

func sendHitSignal():
	hit.emit(self)
