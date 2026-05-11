extends Node

@onready var playerModule: Node = get_parent()

var onAir: bool = false
var isStunned: bool = false
var isDebounced: bool = false
var isMoving: bool = false
var lookDir: int = 1 
var isKnockbacked: bool = false
var knockbackDir: int = 1 
var isDead: bool = false

@onready var StunTimer: Timer = $StunTimer
@onready var DebounceTimer: Timer = $DebounceTimer

func _process(delta):
	if isKnockbacked and not onAir:
		isKnockbacked = false
	if isStunned and StunTimer.time_left <= 0 and not onAir and not isKnockbacked:
		isStunned = false
	if isDebounced and DebounceTimer.time_left <= 0:
		isDebounced = false

################################################################################
#####                             Functions                                #####
################################################################################

func canMove() -> bool:
	if get_parent().get_parent().get_name() == "EnemyDefault":
		pass
	return not (isStunned or isDebounced or isKnockbacked)

func applyStun(time: float):
	if not playerModule.StatsModule.ignoresStun and time > StunTimer.time_left:
		StunTimer.start(time)
		isStunned = true

func applyDebounce(time: float):
	if time > DebounceTimer.time_left:
		DebounceTimer.start(time)
		isDebounced = true

func setLookDir(newDir: float):
	if newDir > 0:
		lookDir = 1
	elif newDir < 0:
		lookDir = -1

func setDead():
	isDead = true
	playerModule.player.dead.emit(playerModule.player)
