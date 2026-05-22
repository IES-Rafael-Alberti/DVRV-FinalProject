extends Node

## Probabilidad global (0.0 a 1.0)
var drop_chance: float = 0.30

## Carga la escena directamente por ruta
var health_potion_scene: PackedScene = preload("res://scenes/HealthPotion.tscn")

func try_drop(position: Vector2) -> void:
	if health_potion_scene == null:
		return
	if randf() > drop_chance:
		return
	
	var loot = health_potion_scene.instantiate()
	loot.global_position = position
	get_tree().current_scene.call_deferred("add_child", loot)
