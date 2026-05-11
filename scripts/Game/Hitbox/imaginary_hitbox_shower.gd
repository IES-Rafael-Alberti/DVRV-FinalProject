extends Node

@export var this: Area2D = get_parent()
@onready var imaginaryHitbox: Sprite2D = $ImaginaryHitbox
@onready var defaultSize: Vector2 = imaginaryHitbox.scale

var thisOwner: CharacterBody2D

# Called when the node enters the scene tree for the first time.
	
func _on_initialized():
	if not this: this = get_parent()
	thisOwner = this.get_parent()
	
	while true:
		imaginaryHitbox.position.y = -thisOwner.PlayerModule.HeightModule.height/this.scale.y
		await get_tree().process_frame
		if !this.followHeight:
			break
