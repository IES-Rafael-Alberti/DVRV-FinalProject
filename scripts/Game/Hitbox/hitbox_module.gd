extends Node

@export var this: Area2D = get_parent()
@onready var thisOwner: CharacterBody2D

@export_category("Values")
@export var damage: int
@export var stuntime: float
@export var knockback: Vector3
@export var targetsAmount: int = 500
@export var friendGroups: Array[StringName]
@export var callOnHit: String
@export var followHeight: bool

@export var disabled: float = false
var inside: Array[CharacterBody2D] = []
var hitted: Array[CharacterBody2D] = []
var newHeight: float = 0

func _process(delta):
	newHeight = this.HitboxMovementModule.height
	newHeight += thisOwner.PlayerModule.HeightModule.height
	for target in inside:
		if isTrulyIn(target) and not hitted.has(target):
			target.PlayerModule.DamageModule.takeDamage(damage,stuntime,knockback*Vector3(this.lookDir,1,1))
			if Callable(this, callOnHit):
				Callable(this, callOnHit).call()
			hitted.append(target)
			inside.erase(target)
			if hitted.size() >= targetsAmount:
				this.LifetimeModule.setDespawnPhase()

################################################################################
#####                              Utility                                 #####
################################################################################

func isTrulyIn(body):
	var thisHitbox = this.get_node("CollisionShape2D")
	var thisRadius = thisHitbox.shape.radius * this.scale.y
	var hitboxYDist = thisHitbox.global_position.y - body.global_position.y
	var bodyHeight = body.PlayerModule.HeightModule.height
	var bodyRadius = body.CollisionBox.shape.radius
	var bodyColPosY = body.CollisionBox.position.y
	
	if bodyHeight + bodyRadius + hitboxYDist - bodyColPosY >= newHeight - thisRadius and bodyHeight - bodyRadius + hitboxYDist - bodyColPosY <= newHeight + thisRadius:
		return true
	return false

func isEnemy(body):
	var enemy = true
	for group in friendGroups:
		if group == "Entity": continue
		if body.is_in_group(group):
			enemy = false
	return enemy

################################################################################
#####                              Signals                                 #####
################################################################################

func _on_body_entered(body):
	if not disabled and body.is_in_group("Entity") and isEnemy(body): 
		inside.append(body)

func _on_body_exit(body):
	if body.is_in_group("Entity") and isEnemy(body):
		inside.erase(body)
