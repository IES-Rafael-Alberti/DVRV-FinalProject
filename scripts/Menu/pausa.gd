extends CanvasLayer

# El nodo de Settings se le asigna a game_hub o se busca automaticamente
var settings_node: Control = null

# Estado actual de pausa
var is_paused: bool = false

func _ready():
	var sl = get_parent().get_node_or_null("SettingsLayer/Settings")
	if sl:
		settings_node = sl
		# Cuando settings se cierra, se vulve a pausar segimos en pausa
		if settings_node.has_signal("settings_closed"):
			settings_node.settings_closed.connect(_on_settings_closed)

func _physics_process(delta):
	if Input.is_action_just_pressed("Pause"):
		# Si los ajustes estan abiertos, dejamos que settings maneje el ESC
		if settings_node and settings_node.visible:
			return
		_toggle_pause()

func _toggle_pause():
	is_paused = not is_paused
	get_tree().paused = is_paused
	$ColorRect.visible = is_paused
	$Label.visible = is_paused
	$ExitButton.visible = is_paused
	$ContinueButton.visible = is_paused
	$RetryButton.visible = is_paused
	if has_node("SettingsButton"):
		$SettingsButton.visible = is_paused

func _on_settings_closed():
	AudioManager.play_sfx("btnSalir")
	# Al cerrar settings el juego sigue pausado, segimos en el menu de pausa
	if is_paused:
		get_tree().paused = true

func _on_exit_button_pressed() -> void:
	AudioManager.play_sfx("btnSalir")
	is_paused = false
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_continue_button_pressed() -> void:
	AudioManager.play_sfx("btn")
	_toggle_pause()


func _on_retry_button_pressed() -> void:
	AudioManager.play_sfx("btn")
	is_paused = false
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_settings_button_pressed() -> void:
		AudioManager.play_sfx("btn")
		if settings_node:
			settings_node.visible = true
