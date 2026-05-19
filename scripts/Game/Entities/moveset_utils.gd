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
	var statusModule = player.PlayerModule.StatusModule
	if target:
		if target.position.x > player.position.x:
			statusModule.setLookDir(1)
		elif target.position.x < player.position.x:
			statusModule.setLookDir(-1)
	
	
func getTargetPos(target: CharacterBody2D):
	return target.global_position

func wait_physics_frames(frames: int) -> void:
	for i in frames:
		await get_tree().physics_frame

################################################################################
#####                           Calculations                               #####
################################################################################

func findClosestTarget(targets: Array[CharacterBody2D]):
	var closest: Node2D = null
	var closest_pos := INF
	
	for target in targets:
		if target == null: continue
		
		var dist: float = player.position.distance_squared_to(target.global_position)
		if dist < closest_pos:
			closest_pos = dist
			closest = target
	
	return closest

func frames_until_zero(height: float, velocity: float, acceleration: float):
	if acceleration >= 0:
		return -1
	var A = acceleration / 2.0
	var B = velocity - acceleration / 2.0
	var C = height

	var discriminant = B * B - 4.0 * A * C

	if discriminant < 0.0:
		return -1.0

	var sqrt_disc = sqrt(discriminant)

	var n1 = (-B + sqrt_disc) / (2.0 * A)
	var n2 = (-B - sqrt_disc) / (2.0 * A)

	return max(n1, n2)
		
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
	hitbox.showHitbox = player.ShowHitboxes
	hitbox.thisOwner = player
	
	if followParent:
		player.add_child(hitbox)
	else:
		player.get_parent().add_child(hitbox)
	return hitbox
