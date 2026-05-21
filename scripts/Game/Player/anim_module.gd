extends Node

@onready var playerModule: Node = get_parent()
@onready var status: Node = playerModule.StatusModule

@export var animTree: AnimationTree

var lastAnim: String = ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not status:
		status = playerModule.StatusModule
		return
		
	playerModule.charShadow.visible = !status.isInvisible
	playerModule.charVisual.visible = !status.isInvisible
	animTree = playerModule.charVisual.get_node("AnimationTree")
	setAim()
	checkAnimSfx()

################################################################################
#####                              Utility                                 #####
################################################################################

func setAim():
	var moving = status.isMoving
	var lookDir = status.lookDir
	var stunned = status.isStunned
	var knockback = status.isKnockbacked
	var onAir = status.onAir
	
	# Anims
	animTree.set("parameters/conditions/Idle",!moving)
	animTree.set("parameters/conditions/Walking",moving)
	animTree.set("parameters/conditions/Stun",stunned)
	animTree.set("parameters/conditions/!Stun",!stunned)
	animTree.set("parameters/conditions/Knockback",knockback)
	animTree.set("parameters/conditions/!Knockback",!knockback)
	animTree.set("parameters/conditions/Jump",onAir)
	animTree.set("parameters/conditions/!Jump",!onAir)
	
	var sm = animTree.get("parameters/playback")
	var current = sm.get_current_node()
	animTree.set("parameters/%s/blend_position" % current, lookDir)
	#animTree.set("parameters/Knockback/blend_position",knockbackDir)

func getCurrentAnim():
	return animTree.get("parameters/playback").get_current_node()

func forceAnim(animName: String):
	if animTree:
		var sm = animTree.get("parameters/playback")
		if animTree.tree_root.has_node(animName):
			sm.start(animName)
	
func resetAnim():
	forceAnim("Idle")

func checkAnimSfx():
	var currentAnim = getCurrentAnim()
	if currentAnim != lastAnim:
		#print("Anim: ", currentAnim)
		match currentAnim:
			"AtkLight1": AudioManager.play_sfx("ataqueBaston")
			"AtkLight2": AudioManager.play_sfx("ataqueBaston")
			"AtkLight3": AudioManager.play_sfx("ataqueBaston")
			"AtkSLagHeavy": AudioManager.play_sfx("cabezazo")
			"Jump": AudioManager.play_sfx("jump")
		lastAnim = currentAnim
