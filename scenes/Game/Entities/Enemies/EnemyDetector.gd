extends Area2D

@onready var this: Node = get_parent()
@onready var playerModule: Node = this.get_node("PlayerModule")

var enemies: Array[CharacterBody2D] = []

func _on_body_entered(body):
	if this.is_in_group("Enemy") and body.is_in_group("Player") or body.is_in_group("Enemy") and this.is_in_group("Player"):
		enemies.append(body)


func _on_body_exited(body):
	if this.is_in_group("Enemy") and body.is_in_group("Player") or body.is_in_group("Enemy") and this.is_in_group("Player"):
		enemies.erase(body)
