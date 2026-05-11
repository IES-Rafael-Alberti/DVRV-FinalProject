extends Node

signal initialized()

@export_category("Input")
@export var playerInput: bool = false

@export_category("Stats")
@export var maxHealth: float = 100
@export var health: float = 100
@export var maxMagic: float = 100
@export var magic: float = 100
@export var speed: Vector2 = Vector2(300,200)

@export_category("Stat Boosts (Unimplemented)")
@export var dmgBoost: float = 0
@export var defBoost: float = 0
@export var speedBoost: float = 0

@export_category("Stat Others")
@export var ignoresKnockback: bool = false
@export var ignoresStun: bool = false ## Turn IgnoreKnockbackWithIt
@export var jPower: float = 20
@export var gravity: float = 1

@export_category("Anim")
@export var animTree: AnimationTree

@export_category("Moveset")
@export var MovesetModule: Node

@onready var player: CharacterBody2D = get_parent()
@onready var MovementModule: Node = $MovementModule
@onready var HeightModule: Node = $HeightModule
@onready var InputModule: Node = $InputModule
@onready var StatusModule: Node = $StatusModule
@onready var StatsModule: Node = $StatsModule
@onready var DamageModule: Node = $DamageModule
@onready var AnimModule: Node = $AnimModule

var isMoving: bool = false
var outsideArea: bool = false

var charVisual: Node2D 
var charShadow: Sprite2D 
var charCollisionBox: CollisionShape2D 
var charAnimOgOffset: float
var charShadowOgSize: Vector2

func _initialized():
	charVisual = player.get_node("Visual")
	charShadow = player.get_node("Shadow")
	charCollisionBox = player.get_node("CollisionBox")
	charAnimOgOffset = charVisual.position.y
	charShadowOgSize = charShadow.scale

	InputModule.playerInput = playerInput
	StatsModule.maxHealth = maxHealth
	StatsModule.health = health
	StatsModule.maxMagic = maxMagic
	StatsModule.magic = magic
	StatsModule.speed = speed
	StatsModule.dmgBoost = dmgBoost
	StatsModule.defBoost = defBoost
	StatsModule.speedBoost = speedBoost
	StatsModule.ignoresKnockback = ignoresKnockback
	StatsModule.ignoresStun = ignoresStun
	StatsModule.jPower = jPower
	StatsModule.gravity = gravity
	AnimModule.animTree = animTree

	initialized.connect(MovesetModule._initialized)
	initialized.emit()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var canMove: bool = StatusModule.canMove()
	
	if canMove:
		MovementModule.setMovement(InputModule.movement, StatsModule.speed)
		
		if InputModule.jumpKey and not StatusModule.onAir:
			HeightModule.jump(StatsModule.jPower)
		if StatusModule.onAir:
			if InputModule.lightAttack and MovesetModule.airAttack:
				MovesetModule.airAttack()
		else:
			if InputModule.lightAttack and MovesetModule.lightAttack:
				MovesetModule.lightAttack()
			if InputModule.heavyAttack and MovesetModule.heavyAttack:
				MovesetModule.heavyAttack()
	else:
		StatusModule.isMoving = false
