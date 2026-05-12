class_name Settings
extends Control

signal settings_closed

func _ready() -> void:
	_load_last_tab()


	

func _load_last_tab() -> void:
	var tab_container = get_node_or_null("MarginContainer/TabContainer")
	if tab_container:
		var last_tab: int = get_node("/root/ConfigManager").get_setting("settings", "last_tab", 0)
		tab_container.current_tab = last_tab
		tab_container.tab_changed.connect(_on_tab_changed)

func _on_tab_changed(tab_index: int) -> void:
	get_node("/root/ConfigManager").set_setting("settings", "last_tab", tab_index)

func show_settings() -> void:
	visible = true


func _on_open_from_game() -> void:
	visible = true
	get_tree().paused = true


func _on_close_from_game() -> void:
	get_tree().paused = false


func _on_close_button_pressed() -> void:
	visible = false
	if get_tree().paused:
		get_tree().paused = false
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
	visible = false
	if get_tree().paused:
		get_tree().paused = false
	settings_closed.emit()


func _on_option_button_pressed() -> void:
	pass # Replace with function body.
