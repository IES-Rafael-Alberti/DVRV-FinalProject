extends Node

const CONFIG_FILE_PATH: String = "user://game_settings.cfg"
var config: ConfigFile = ConfigFile.new()


func _ready() -> void:
	_load_config()


func _load_config() -> void:
	var err := config.load(CONFIG_FILE_PATH)
	if err != OK:
		print("No existing config file found, using default settings.")
	else:
		print("Config file loaded successfully.")


func save_config() -> void:
	config.save(CONFIG_FILE_PATH)


func get_setting(section: String, key: String, default: Variant) -> Variant:
	return config.get_value(section, key, default)


func set_setting(section: String, key: String, value: Variant) -> void:
	config.set_value(section, key, value)
	save_config()
