extends Node
# Módulo de muerte específico para el jugador

signal player_died

@export var deathTime: float = 1.5
@export var deathAnim: StringName = "Knockback"

func onDeath(this: CharacterBody2D):
	var playerModule = this.PlayerModule
	
	this.remove_from_group("Entity")
	playerModule.StatusModule.applyStun(10000)
	playerModule.AnimModule.forceAnim(deathAnim)
	
	# Espera la animación de muerte
	await get_tree().create_timer(deathTime).timeout
	
	# Parpadeo de muerte 
	for i in range(4):
		playerModule.AnimModule.forceAnim(deathAnim)
		await get_tree().create_timer(0.2).timeout
		this.visible = !this.visible
	this.visible = false
	
	# Señal para que el GameManager muestre el Game Over
	player_died.emit()
