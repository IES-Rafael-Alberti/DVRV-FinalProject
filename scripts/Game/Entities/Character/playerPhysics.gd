extends CharacterBody2D

signal initialized()
signal dead(this: CharacterBody2D)


@export_category("Outside")
@export var MovingArea: Area2D
@export var Camera: Camera2D

@export_category("InNode")
@export var DeathNode: Node
@export var AIModule: Node2D
@export var FlyingModule: Node
@onready var PlayerModule: Node = $PlayerModule
@onready var CollisionBox: CollisionShape2D = $CollisionBox

var ShowCollisions: bool
var ShowHitboxes: bool

func _ready():
	if MovingArea: 
		PlayerModule.MovementModule.MovingArea = MovingArea
		PlayerModule.MovementModule.boundryPolygon = MovingArea.get_node("CollisionPolygon2D").polygon
	else:
		push_warning("MovingArea not found in ", name)
		
	
	initialized.connect(PlayerModule._initialized)
	initialized.emit()
	if DeathNode:
		dead.connect(DeathNode.onDeath)
		
	$CollisionBox.visible = ShowCollisions
	
func _physics_process(delta):
	PlayerModule.HeightModule._heightProcess(delta)
	PlayerModule.MovementModule._movementProcess(delta)
	if AIModule:
		AIModule._AIProcess(delta)
	if FlyingModule:
		FlyingModule._flyingProcess(delta)
