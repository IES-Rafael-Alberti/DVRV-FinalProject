extends Node

@onready var settings_node: Control = $SettingsLayer/Settings
@onready var pausa_node: CanvasLayer = $Pausa
 
 
func _on_settings_button_pressed():
	get_tree().paused = true
	settings_node.visible = true
 
 
func _on_pause_button_pressed():
	pausa_node._toggle_pause()
 
