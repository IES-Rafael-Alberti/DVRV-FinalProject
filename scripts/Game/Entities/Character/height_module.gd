extends Node

@onready var playerModule: Node = get_parent()
var character: CharacterBody2D

var height: float
var heightSpeed: float

func _heightProcess(delta):
	if not playerModule:
		playerModule = get_parent()
		return
		
	if playerModule.StatusModule.onAir:
		calculateHeight()
		setPosY(playerModule.charVisual, playerModule.charAnimOgOffset)
		setPosY(playerModule.charCollisionBox.get_node("ImaginarySprite2D"), 0)
		
	var shadowSize: float = lerp(0.0, 1.0, 1/(height/100+1))
	playerModule.charShadow.scale = playerModule.charShadowOgSize * shadowSize
	
################################################################################
#####                             Functions                                #####
################################################################################

func jump(jPower: float):
	if height <= 0:
		height += 1
	heightSpeed = jPower
	setOnAir()
	
func setHeight(newHeight: float):
	height = newHeight
	setOnAir()

func addHeight(newHeight: float):
	setHeight(newHeight-height)

func addHeightSpeed(newHeightSpeed: float):
	jump(newHeightSpeed+heightSpeed)
	
################################################################################
#####                              Utility                                 #####
################################################################################

func setOnAir():
	playerModule.StatusModule.onAir = true

func calculateHeight():
	heightSpeed -= playerModule.StatsModule.gravity
	
	if height <= 0 and heightSpeed < 0:
		height = 0
		heightSpeed = 0
		playerModule.StatusModule.onAir = false
		
	height += heightSpeed;

func setPosY(node: Node2D, offset: float):
	if node:
		var newPosY = -height + offset
		node.position.y = newPosY if newPosY < 0 else 0
