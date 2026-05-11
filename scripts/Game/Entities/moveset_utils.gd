extends Node

@export var hitboxPacked: PackedScene
@onready var player: Node = get_parent().get_parent()

################################################################################
#####                              Utility                                 #####
################################################################################

func spawnHitbox(lookDir, positionOffset, intMovementDir, AccelerationDir, scale, lifetime, damage, stuntime, knockback, followParent: bool = true, dmgSelf: bool = false):
	var hitbox = hitboxPacked.instantiate()
	if not dmgSelf:
		hitbox.friendGroups = player.get_groups() if not dmgSelf else []
	
	var offset = positionOffset
	hitbox.global_position = Vector2(offset[0]*lookDir,offset[2]-offset[1]) + (player.position if !followParent else Vector2.ZERO)
	hitbox.intMovementDir = intMovementDir*Vector3(lookDir,1,1)
	hitbox.AccelerationDir = AccelerationDir*Vector3(lookDir,1,1)
	hitbox.height = offset[1] + player.PlayerModule.HeightModule.height if !followParent else 0
	hitbox.scale *= scale
	hitbox.lifeTime = lifetime
	hitbox.damage = damage
	hitbox.stuntime = stuntime
	hitbox.knockback = knockback*Vector3(lookDir,1,1)
	hitbox.followHeight = followParent
	hitbox.top_level = !followParent
	hitbox.showHitbox = player.ShowHitboxes
	player.add_child(hitbox)
	return hitbox
