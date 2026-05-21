class_name Settings
extends Control

signal settings_closed

func _ready() -> void:
	_load_last_tab()


func _load_last_tab() -> void:
	var tab_container = get_node_or_null("SettingsCenter/SettingsPanel/MainVB/BodyMargin/TabContainer")
	if tab_container:
		var config_manager = get_node_or_null("/root/ConfigManager")
		if config_manager:
			var last_tab: int = config_manager.get_setting("settings", "last_tab", 0)
			tab_container.current_tab = last_tab
			tab_container.tab_changed.connect(_on_tab_changed)

func _on_tab_changed(tab_index: int) -> void:
	var config_manager = get_node_or_null("/root/ConfigManager")
	if config_manager:
		config_manager.set_setting("settings", "last_tab", tab_index)

func show_settings() -> void:
	visible = true


#func _on_open_from_game() -> void:
	#visible = true
	#get_tree().paused = true


#func _on_close_from_game() -> void:
	#get_tree().paused = false


func _on_close_button_pressed() -> void:
	AudioManager.play_sfx("btnSalir")
	visible = false
	settings_closed.emit()
	
	
func get_all_buttons(node: Node) -> Array:
	var buttons = []
	for child in node.get_children():
		if child is Button:
			buttons.append(child)
		buttons += get_all_buttons(child)
	return buttons


#boton para volver al menu
func _on_button_pressed() -> void:
	AudioManager.play_sfx("btn")
	visible = false
	settings_closed.emit()


func _on_option_button_pressed() -> void:
	AudioManager.play_sfx("btn")
	pass # Replace with function body.


func _on_gear_btn_pressed() -> void:
	AudioManager.play_sfx("btn")
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	AudioManager.play_sfx("btnSalir")
	visible = false
	settings_closed.emit()

# Cerrar con ESC
func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("Pause") or event.is_action_pressed("ui_cancel"):
		visible = false
		settings_closed.emit()
		get_viewport().set_input_as_handled()
