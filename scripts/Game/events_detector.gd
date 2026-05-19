extends Node2D

@export var waveEvents: Array[Area2D] = []

@export_category("WavesGeneral")
@export var waveCompletedEndlag: float = 2.0

@onready var game: Node2D = get_parent()
@onready var EnemiesNode: Node2D = game.get_node("Enemies")
@onready var PlayerFollower: Node2D = game.get_node("PlayerFollower")

# Called when the node enters the scene tree for the first time.
func _ready():
	var wavNum = 1
	for wave in waveEvents:
		wave.Activated.connect(Callable(self, "wave"+str(wavNum)))
		wavNum += 1
		
	
################################################################################
#####                              Events                                  #####
################################################################################

func wave1():
	setCameraFollow(false)
	for i in range(0,2):
		EnemiesNode.spawnEnemy("Grimp")
		await get_tree().create_timer(0.5).timeout
	await waitUntilEnemyClear()
	finishWave()

func wave2():
	setCameraFollow(false)
	for i in range(0,6):
		EnemiesNode.spawnEnemy("Grimp")
		await get_tree().create_timer(randf_range(0.2,1.5)).timeout
	await waitUntilEnemyClear()
	finishWave()

func wave3():
	setCameraFollow(false)
	EnemiesNode.spawnEnemy("Pumpumf")
	await waitUntilEnemyClear()
	finishWave()
	
func wave4():
	setCameraFollow(false)
	EnemiesNode.spawnEnemy("Pumpumf")
	await get_tree().create_timer(0.5).timeout
	EnemiesNode.spawnEnemy("Pumpumf")
	for i in range(0,6):
		EnemiesNode.spawnEnemy("Grimp", false)
		await get_tree().create_timer(randf_range(0.2,0.7)).timeout
	await waitUntilEnemyClear()
	finishWave()
	
func wave5():
	setCameraFollow(false)
	EnemiesNode.spawnEnemy("Flyby")
	await waitUntilEnemyClear()
	await get_tree().create_timer(1.0).timeout
	
	for i in range(0,2):
		EnemiesNode.spawnEnemy("Pumpumf")
		await get_tree().create_timer(randf_range(0.2,0.7)).timeout
	EnemiesNode.spawnEnemy("Flyby", false)
	for i in range(0,2):
		EnemiesNode.spawnEnemy("Grimp", false)
	EnemiesNode.spawnEnemy("Flyby")
	await waitUntilEnemyClear()
	finishWave()
	
func wave6():
	setCameraFollow(false)
	while true:
		match randi_range(0,4):
			0:
				EnemiesNode.spawnEnemy("Grimp")
			1:
				EnemiesNode.spawnEnemy("Flyby")
			2:
				EnemiesNode.spawnEnemy("Pumpumf")
			3:
				EnemiesNode.spawnEnemy("Spiffer")
		await get_tree().create_timer(2).timeout
	pass
	
################################################################################
#####                              Utility                                 #####
################################################################################

func setCameraFollow(follow: bool):
	PlayerFollower.FollowPlayer = follow

func waitUntilEnemyClear():
	var enemies = EnemiesNode.spawnedEnemies
	while not EnemiesNode.spawnedEnemies.is_empty():
		await get_tree().process_frame

func finishWave():
	await get_tree().create_timer(waveCompletedEndlag).timeout
	setCameraFollow(true)
