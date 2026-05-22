extends Settings

# Mapa de índice -> [nodo_botón, locale]
const LANGUAGES = [
	["PageLang/LangES", "es"],
	["PageLang/LangEN", "en"],
]

# Cambia estas rutas a tus SVGs reales si los tienes
const ICON_SELECTED   = preload("res://assets/Prinbles_YetAnotherIcons (beta) (9_7_2023)/svg/White-Icon/Sound-Three.svg") # placeholder
const ICON_UNSELECTED = preload("res://assets/Prinbles_YetAnotherIcons (beta) (9_7_2023)/svg/White-Icon/Sound-None.svg")  # placeholder

var _buttons: Array = []

func _ready() -> void:
	_load_language_preference()
	_setup_buttons()

func _setup_buttons() -> void:
	for entry in LANGUAGES:
		var btn = get_node_or_null(entry[0])
		if btn == null:
			continue
		btn.toggle_mode = true
		btn.button_pressed = false
		btn.toggled.connect(_on_lang_button_toggled.bind(entry[1]))
		_buttons.append({"node": btn, "locale": entry[1]})

	# Marcar el botón activo según el idioma actual
	_refresh_button_states(TranslationServer.get_locale())

func _on_lang_button_toggled(_pressed: bool, locale: String) -> void:
	# Aunque el botón se desactive, siempre aplicamos el idioma al pulsar
	change_language_by_locale(locale)
	AudioManager.play_sfx("btn")

func change_language_by_locale(locale: String) -> void:
	TranslationServer.set_locale(locale)
	_save_language_preference(locale)
	_refresh_button_states(locale)

func _refresh_button_states(active_locale: String) -> void:
	for entry in _buttons:
		var btn: Button = entry["node"]
		var is_active: bool = active_locale.begins_with(entry["locale"])
		
		# Desconectar temporalmente para evitar recursión
		if btn.toggled.is_connected(_on_lang_button_toggled):
			btn.toggled.disconnect(_on_lang_button_toggled)
			
		btn.button_pressed = is_active
		
		# Reconectar
		btn.toggled.connect(_on_lang_button_toggled.bind(entry["locale"]))
		# Aquí cambias el ícono del círculo
		# btn.icon = ICON_SELECTED if is_active else ICON_UNSELECTED

func _load_language_preference() -> void:
	var locale: String = "en"
	if OS.get_name() == "Web":
		locale = _load_language_from_localstorage()
	else:
		locale = get_node("/root/ConfigManager").get_setting("language", "locale", "en")
	TranslationServer.set_locale(locale)

func _load_language_from_localstorage() -> String:
	if OS.get_name() == "Web":
		var result = JavaScriptBridge.eval("localStorage.getItem('game_language') || 'en'")
		return result if result else "en"
	return "en"

func _save_language_preference(locale: String) -> void:
	get_node("/root/ConfigManager").set_setting("language", "locale", locale)
	if OS.get_name() == "Web":
		JavaScriptBridge.eval("localStorage.setItem('game_language', '" + locale + "')")
