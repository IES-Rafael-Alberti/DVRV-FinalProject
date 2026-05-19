extends Node

@onready var playerModule: Node = get_parent()
@export var knockbackStatusPoint: float = 5

################################################################################
#####                             Functions                                #####
################################################################################

func takeDamage(damage: int, stundur: float, knockback: Vector3):
	if !playerModule.StatusModule.canBeDamaged:
		return
	playerModule.StatsModule.health -= damage
	var stunTime = 0 if playerModule.StatsModule.ignoresStun else 0.01 + stundur if !playerModule.StatsModule.ignoresKnockback else min(0.3,0.01 + stundur)
	playerModule.StatusModule.applyStun(stunTime)
	playerModule.AnimModule.forceAnim("Stun")
	applyKnockback(knockback)
	
	if playerModule.StatsModule.health <= 0:
		playerModule.StatusModule.setDead()

################################################################################
#####                              Utility                                 #####
################################################################################

func applyKnockback(knockback: Vector3):
	if playerModule.StatsModule and not playerModule.StatsModule.ignoresKnockback:
		playerModule.MovementModule.moveTo(Vector2.ZERO, Vector2.ZERO)
		playerModule.MovementModule.applyForce(Vector2(knockback.x, knockback.z), knockback.y)
		
		playerModule.StatusModule.setLookDir(-int(knockback.x) if int(knockback.x) != 0 else playerModule.StatusModule.lookDir)
		if knockback.y > knockbackStatusPoint or knockback.y < 0:
			playerModule.StatusModule.isKnockbacked = true
