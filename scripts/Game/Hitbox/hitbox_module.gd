extends Node

@export var this: Area2D = get_parent()
@onready var thisOwner: CharacterBody2D = this.get_parent()

@export_category("Values")
@export var damage: int
@export var height: int
@export var stuntime: float
@export var knockback: Vector3
@export var targetsAmount: int = 500
@export var friendGroups: Array[StringName]
@export var callOnHit: String
@export var followHeight: bool

var inside: Array[CharacterBody2D] = []
var hitted: Array[CharacterBody2D] = []
var newHeight: float = 0

func _ready():
	this.body_entered.connect(_on_body_entered)
	this.body_exited.connect(_on_body_exit)

func _process(delta):
	newHeight = height
	if followHeight:
		newHeight += thisOwner.PlayerModule.HeightModule.height
	for target in inside:
		if isTrulyIn(target) and not hitted.has(target):
			target.PlayerModule.DamageModule.takeDamage(damage,stuntime,knockback)
			if Callable(this, callOnHit):
				Callable(this, callOnHit).call()
			hitted.append(target)
			inside.erase(target)
			if hitted.size() >= targetsAmount:
				get_parent().queue_free()

################################################################################
#####                              Utility                                 #####
################################################################################

func isTrulyIn(body):
	var thisRadius = this.get_node("CollisionShape2D").shape.radius * this.scale.y
	var bodyHeight = body.PlayerModule.HeightModule.height
	var bodyRadius = body.CollisionBox.shape.radius
	var bodyColPosY = body.CollisionBox.global_position + Vector2(0,bodyHeight)
	#print(bodyHeight+bodyRadius, " + ", newHeight - thisRadius, "  -  ", bodyHeight-bodyRadius, " + ", newHeight + thisRadius)
	if bodyHeight >= newHeight - thisRadius and bodyHeight <= newHeight + thisRadius:
		if bodyColPosY.distance_to(this.global_position + Vector2(0,bodyHeight)) <= thisRadius + bodyRadius:
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
	if body.is_in_group("Entity") and isEnemy(body): 
		inside.append(body)

func _on_body_exit(body):
	if body.is_in_group("Entity") and isEnemy(body):
		inside.erase(body)
