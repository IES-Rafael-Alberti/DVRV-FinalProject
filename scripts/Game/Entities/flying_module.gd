extends Node

@export var playerModule: Node = get_parent()

@export_category("Values")
@export var flyHeight: int = 150
@export var maxFlySpeed: float = 0.1
@export var stoppingSpeed: float = 0.05

func _flyingProcess(delta):
	if !playerModule.StatusModule.isStunned:
		var height = playerModule.HeightModule.height
		var heightSpeed = playerModule.HeightModule.heightSpeed
		
		playerModule.HeightModule.addHeightSpeed(1+max(-maxFlySpeed,min(maxFlySpeed,flyHeight - height)))
		if abs(heightSpeed) > 2:
			playerModule.HeightModule.addHeightSpeed(max(-stoppingSpeed,min(stoppingSpeed,-heightSpeed)))
