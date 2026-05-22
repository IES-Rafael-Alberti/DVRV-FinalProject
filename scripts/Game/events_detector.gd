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
		if not is_inside_tree(): return
		await get_tree().create_timer(0.5).timeout
	await waitUntilEnemyClear()
	if not is_inside_tree(): return
	finishWave()

func wave2():
	setCameraFollow(false)
	for i in range(0,6):
		EnemiesNode.spawnEnemy("Grimp")
		if not is_inside_tree(): return
		await get_tree().create_timer(randf_range(0.2,1.5)).timeout
	await waitUntilEnemyClear()
	if not is_inside_tree(): return
	finishWave()

func wave3():
	setCameraFollow(false)
	EnemiesNode.spawnEnemy("Pumpumf")
	await waitUntilEnemyClear()
	if not is_inside_tree(): return
	finishWave()
	
func wave4():
	setCameraFollow(false)
	EnemiesNode.spawnEnemy("Pumpumf")
	if not is_inside_tree(): return
	await get_tree().create_timer(0.5).timeout
	if not is_inside_tree(): return
	EnemiesNode.spawnEnemy("Pumpumf")
	for i in range(0,6):
		EnemiesNode.spawnEnemy("Grimp", false)
		if not is_inside_tree(): return
		await get_tree().create_timer(randf_range(0.2,0.7)).timeout
	await waitUntilEnemyClear()
	if not is_inside_tree(): return
	finishWave()
	
func wave5():
	setCameraFollow(false)
	EnemiesNode.spawnEnemy("Flyby")
	await waitUntilEnemyClear()
	if not is_inside_tree(): return
	await get_tree().create_timer(1.0).timeout
	if not is_inside_tree(): return
	
	for i in range(0,2):
		EnemiesNode.spawnEnemy("Pumpumf")
		if not is_inside_tree(): return
		await get_tree().create_timer(randf_range(0.2,0.7)).timeout
	if not is_inside_tree(): return
	EnemiesNode.spawnEnemy("Flyby", false)
	for i in range(0,2):
		EnemiesNode.spawnEnemy("Grimp", false)
	EnemiesNode.spawnEnemy("Flyby")
	await waitUntilEnemyClear()
	if not is_inside_tree(): return
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
		if not is_inside_tree(): return
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
		if not is_inside_tree(): return
		await get_tree().process_frame

func finishWave():
	if not is_inside_tree(): return
	await get_tree().create_timer(waveCompletedEndlag).timeout
	if not is_inside_tree(): return
	setCameraFollow(true)
