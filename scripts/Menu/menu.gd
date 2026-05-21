extends Control

@onready var settings: Control = $Settings
@onready var credit: Control = $Credit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MusicManager.play_menu()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_play_button_pressed() -> void:
	AudioManager.play_sfx("btn")

	get_tree().change_scene_to_file("res://scenes/cutscene.tscn")
	

func _on_credit_button_pressed() -> void:
	AudioManager.play_sfx("btn")
	credit.visible = true


func _on_exit_button_pressed() -> void:
	AudioManager.play_sfx("btnSalir")
	get_tree().quit()


func _on_option_button_pressed() -> void:
	AudioManager.play_sfx("btn")
	settings.visible = true


func _on_gear_btn_pressed() -> void:
	AudioManager.play_sfx("btn")
	pass # Replace with function body.
