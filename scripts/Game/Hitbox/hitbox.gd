extends Area2D

signal initialized()
signal hit(this: Node2D)

@export_category("Nodes")
@export var HitboxModule: Node
@export var HitboxMovementModule: Node
@export var LifetimeModule: Node
@export var ProyectileAnim: Node
@export var ImaginaryHitbox: Node2D
@export var Visual: Node2D

@export_category("Movement Values")
@export var lookDir: int = 1
@export var intMovementDir: Vector3
@export var AccelerationDir: Vector3

@export_category("Hitbox Values")
@export var thisOwner: CharacterBody2D
@export var damage: int
@export var height: int
@export var stuntime: float
@export var knockback: Vector3
@export var targetsAmount: int = 500
@export var friendGroups: Array[StringName]
@export var followHeight: bool = true

@export_category("LIfeTime Values")
@export var lifeTime: float = -1

@export_category("Debug")
@export var showHitbox: bool = false

func _ready():
	HitboxMovementModule.intMovementDir = intMovementDir
	HitboxMovementModule.AccelerationDir = AccelerationDir
	HitboxMovementModule.lookDir = lookDir
	HitboxMovementModule.intHeight = height
	$HitboxSprite.visible = showHitbox
	ImaginaryHitbox.visible = showHitbox
	HitboxModule.damage = damage
	HitboxModule.stuntime = stuntime
	HitboxModule.thisOwner = thisOwner
	HitboxModule.knockback = knockback
	HitboxModule.targetsAmount = targetsAmount
	HitboxModule.friendGroups = friendGroups
	HitboxModule.callOnHit = "sendHitSignal"
	HitboxModule.followHeight = followHeight
	LifetimeModule.lifeTime = lifeTime
	initialized.emit()
	
	if !showHitbox:
		ImaginaryHitbox.queue_free()
		ImaginaryHitbox = null

func sendHitSignal():
	hit.emit(self)
