extends Node

@export var setMovement = true
@export var this: Area2D
@export var lookDir: int
@export var intMovementDir: Vector3
@export var AccelerationDir: Vector3
@export var intHeight: float
@export var deathHeight: float
@export var followHeight: bool

@onready var thisOwner: CharacterBody2D
@onready var proyectile: Area2D = get_parent()

var velocity: Vector3 = Vector3.ZERO
var height: float = 0
var playerHeight: float = 0

func _on_initialized():
	this = get_parent()
	velocity = intMovementDir*Vector3(lookDir,1,1)
	height = intHeight
	playerHeight = thisOwner.PlayerModule.HeightModule.height 
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if setMovement:
		if followHeight: 
			height -= playerHeight - thisOwner.PlayerModule.HeightModule.height
			playerHeight = thisOwner.PlayerModule.HeightModule.height
		velocity += AccelerationDir*Vector3(lookDir,1,1)
		proyectile.position += Vector2(velocity.x,0+velocity.z)
		if proyectile.Visual:
			proyectile.Visual.position.y = -height/this.scale.y
		height += velocity.y
	
	if height < 0:
		setMovement = false
		this.LifetimeModule.setDespawnPhase()
		AccelerationDir = Vector3.ZERO
		intMovementDir = Vector3.ZERO
		height = 0
