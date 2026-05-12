extends Control

@onready var settings: Control = $Settings
@onready var credit: Control = $Credit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:

	get_tree().change_scene_to_file("res://scenes/Game/Gametest.tscn")
	

func _on_credit_button_pressed() -> void:
	credit.visible = true


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_option_button_pressed() -> void:
	settings.visible = true
