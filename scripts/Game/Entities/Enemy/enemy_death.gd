extends Node

@export var deathTime: float = 2
@export var despawnTime: float = 1

func onDeath(this: CharacterBody2D):
	var playerModule = this.PlayerModule

	this.remove_from_group("Entity")
	playerModule.StatusModule.applyStun(10000)
	playerModule.AnimModule.forceAnim("Knockback")
	await get_tree().create_timer(deathTime).timeout
	despawnAnim(this)
	await get_tree().create_timer(despawnTime).timeout
	this.queue_free()

func despawnAnim(this: CharacterBody2D):
	var playerModule = this.PlayerModule
	while true:
		playerModule.AnimModule.forceAnim("Knockback")
		await get_tree().create_timer(0.3).timeout
		this.visible = !this.visible
