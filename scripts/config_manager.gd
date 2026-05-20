extends Node

const CONFIG_FILE_PATH: String = "user://game_settings.cfg"
var config: ConfigFile = ConfigFile.new()


func _ready() -> void:
	_load_config()
	_apply_saved_controls()


func _load_config() -> void:
	var err := config.load(CONFIG_FILE_PATH)
	if err != OK:
		print("No existing config file found, using default settings.")
	else:
		print("Config file loaded successfully.")


# Aplica los controles guardados al InputMap nada más arrancar el juego,
# para que no haga falta abrir Settings antes de jugar.
func _apply_saved_controls() -> void:
	var actions: PackedStringArray = ["MoveUp", "MoveRight", "MoveDown", "MoveLeft", "LightAttack", "HeavyAttack", "Jump", "MagicAttack"]
	
	for action in actions:
		var saved_keycode: int = get_setting("controls", action, -1)
		if saved_keycode < 0:
			continue
		if not InputMap.has_action(action):
			continue
		
		# Conservarmos eventos que no sean de teclado (gamepad)
		var non_key_events: Array[InputEvent] = []
		for ev in InputMap.action_get_events(action):
			if not ev is InputEventKey:
				non_key_events.append(ev)
		
		InputMap.action_erase_events(action)
		for ev in non_key_events:
			InputMap.action_add_event(action, ev)
			
		var new_ev := InputEventKey.new()
		new_ev.physical_keycode = saved_keycode
		new_ev.device = -1
		InputMap.action_add_event(action, new_ev)

func save_config() -> void:
	config.save(CONFIG_FILE_PATH)


func get_setting(section: String, key: String, default: Variant) -> Variant:
	return config.get_value(section, key, default)


func set_setting(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)
	save_config()
