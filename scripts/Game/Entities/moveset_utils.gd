extends Node

@export var hitboxPacked: PackedScene
@onready var player: Node = get_parent().get_parent()

################################################################################
#####                             Functions                                #####
################################################################################

func defaultJump():
	player.PlayerModule.HeightModule.setHeightSpeed(player.PlayerModule.StatsModule.jPower)

################################################################################
#####                              Utility                                 #####
################################################################################

func tpToPosition(target: Vector2):
	player.position = target
	
func lookPlayer(target: CharacterBody2D):
	var playerModule = player.PlayerModule
	
func getTargetPos(target: CharacterBody2D):
	pass

################################################################################
#####                              Spawner                                 #####
################################################################################

func spawnHitbox(lookDir, positionOffset = Vector3.ZERO, intMovementDir = null, AccelerationDir = null, scale = null, lifetime = null, damage = null, stuntime = null, knockback = null, followParent: bool = true, dmgSelf: bool = false, targetsAmount = null):
	return spawnProyectile(
		hitboxPacked, 
		lookDir, 
		positionOffset, 
		intMovementDir, 
		AccelerationDir, 
		scale, 
		lifetime, 
		damage, 
		stuntime, 
		knockback,
		followParent, 
		dmgSelf,
		targetsAmount
	)

func spawnProyectile(proyectile, lookDir, positionOffset = Vector3.ZERO, intMovementDir = null, AccelerationDir = null, scale = null, lifetime = null, damage = null, stuntime = null, knockback = null, followParent: bool = true, dmgSelf: bool = false, targetsAmount = null):
	var hitbox = proyectile.instantiate()
	if not dmgSelf:
		hitbox.friendGroups = player.get_groups() if not dmgSelf else []
	
	var offset = positionOffset
	hitbox.lookDir = lookDir
	hitbox.global_position = Vector2(offset[0]*lookDir,offset[2]-offset[1]) + (player.position if !followParent else Vector2.ZERO)
	if intMovementDir: hitbox.intMovementDir = intMovementDir*Vector3(1,1,1)
	if AccelerationDir: hitbox.AccelerationDir = AccelerationDir*Vector3(1,1,1)
	hitbox.height = offset[1] + player.PlayerModule.HeightModule.height if !followParent else 0
	if scale: hitbox.scale *= scale
	if lifetime: hitbox.lifeTime = lifetime
	if damage: hitbox.damage = damage
	if stuntime: hitbox.stuntime = stuntime
	if knockback: hitbox.knockback = knockback*Vector3(1,1,1)
	if targetsAmount: hitbox.targetsAmount = targetsAmount
	hitbox.followHeight = followParent
	hitbox.top_level = !followParent
	if followParent: hitbox.z_index = player.z_index
	hitbox.showHitbox = player.ShowHitboxes
	player.add_child(hitbox)
	return hitbox
