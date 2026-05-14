extends Node

@export var node: Node = get_parent()
@export_category("Values")
@export var lifeTime: float = -2

@export var despawnTime: float = 1
@export var despawnAnim: StringName = "Hit"

var despawning = false

func _on_initialized():
	await get_tree().create_timer(0.1).timeout
	if lifeTime >= 0:
		await get_tree().create_timer(lifeTime).timeout 
		setDespawnPhase()

func setDespawnPhase():
	if not despawning:
		despawning = true
		node.HitboxModule.disabled = true
		if not node.ProyectileAnim:
			node.queue_free()
		else:
			
			var hitboxAnim = node.ProyectileAnim
			
			hitboxAnim.followRotation = false
			node.HitboxMovementModule.velocity *= Vector3(0,1,1)
			node.HitboxMovementModule.AccelerationDir *= Vector3(0,1,1)
			node.Visual.rotation = 0
			if node.Visual.position.y >= 0:
				node.Visual.position.y = 0
			hitboxAnim.forceAnim(despawnAnim)
			await get_tree().create_timer(despawnTime).timeout 
			node.queue_free()
