extends Node2D

@export var enemies: Array[PackedScene] = []

@onready var Game: Node2D = get_parent()

var spawnedEnemies: Array[Node2D] = []

################################################################################
#####                             Functions                                #####
################################################################################

func spawnEnemy(name: String, right: bool = true):
	var selected: PackedScene
	for enemy in enemies:
		if enemy.resource_path.get_file().get_basename() == name:
			selected = enemy
			break;
	if selected:
		var instance = selected.instantiate()
		instance.position = Game.gameCamera.position + (Vector2(1000,0) if right else Vector2(-1000,0))
		instance.MovingArea = Game.mapBoundry
		instance.Camera = Game.gameCamera
		instance.ShowCollisions = Game.ShowCollisions
		instance.ShowHitboxes = Game.ShowHitboxes
		addToList(instance)
		call_deferred("add_child", instance)
		return instance

################################################################################
#####                              Utility                                 #####
################################################################################

func addToList(enemy: Node2D):
	spawnedEnemies.append(enemy)
	enemy.dead.connect(removeFromList)

func removeFromList(enemy: Node2D):
	spawnedEnemies.erase(enemy)
