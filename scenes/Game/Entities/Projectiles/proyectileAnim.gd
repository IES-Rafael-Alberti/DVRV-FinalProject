extends Node

@export var followRotation = true

@export var this: Area2D = get_parent()
@export var animTree: AnimationTree

# Called when the node enters the scene tree for the first time.
func _process(delta):
	var sm = animTree.get("parameters/playback")
	var current = sm.get_current_node()
	var velocity = this.HitboxMovementModule.velocity
	animTree.set("parameters/%s/blend_position" % current, velocity.x)
	
	if followRotation:
		this.Visual.look_at(this.Visual.global_position + Vector2(velocity.x,-velocity.y)*this.lookDir)

func forceAnim(animName: String):
	if animTree:
		var sm = animTree.get("parameters/playback")
		if animTree.tree_root.has_node(animName):
			sm.start(animName)
