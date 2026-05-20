extends MarginContainer

# Mapeo entre el ID interno de cada fila de la UI y la acción del InputMap.
# Las claves son los sufijos de los nodos (Up, Right, Down, Left, B1, B2, B3, B4).
# Los valores son los nombres de acción exactos tal como lo tenemos en el project.godot.
const ACTION_MAP: Dictionary = {
	"Up":    "MoveUp",
	"Right": "MoveRight",
	"Down":  "MoveDown",
	"Left":  "MoveLeft",
	"B1":    "LightAttack",
	"B2":    "HeavyAttack",
	"B3":    "Jump",
	"B4":    "MagicAttack",
}

# Referencia a los botones KeyCap de la UI
var key_buttons: Dictionary = {}

# Estilos para el estado normal y escuchando de los KeyCap
var _style_normal: StyleBoxFlat
var _style_listening: StyleBoxFlat

# ID de las acciones que estan esperando una tecla (null si ninguna)
var _listening_id: String = ""

func _ready() -> void:
	_build_styles()
	_discover_key_buttons()
	_load_saved_binds()
	_refresh_all_labels()
	

# ─── Inicialización ──────────────────────────────────────────────────────────
# Crea los StyleBox para los dos estados del KeyCap.
func _build_styles() -> void:
	# Normal: fondo crema, borde ink, sombra chunky (ya existe en la escena).
	_style_normal = StyleBoxFlat.new()
	_style_normal.bg_color = Color(0.957, 0.918, 0.824, 1)  # cream
	_style_normal.border_width_left = 4
	_style_normal.border_width_top = 4
	_style_normal.border_width_right = 4
	_style_normal.border_width_bottom = 4
	_style_normal.border_color = Color(0.102, 0.078, 0.063, 1)  # ink
	_style_normal.corner_radius_top_left = 12
	_style_normal.corner_radius_top_right = 12
	_style_normal.corner_radius_bottom_left = 12
	_style_normal.corner_radius_bottom_right = 12
	_style_normal.shadow_color = Color(0.102, 0.078, 0.063, 1)
	_style_normal.shadow_size = 5
	_style_normal.shadow_offset = Vector2(0, 5)
	_style_normal.content_margin_left = 12
	_style_normal.content_margin_right = 12
 
	# Listening: fondo rose, sin sombra (hundido).
	_style_listening = StyleBoxFlat.new()
	_style_listening.bg_color = Color(0.769, 0.416, 0.416, 1)  # rose (#c46a6a)
	_style_listening.border_width_left = 4
	_style_listening.border_width_top = 4
	_style_listening.border_width_right = 4
	_style_listening.border_width_bottom = 4
	_style_listening.border_color = Color(0.102, 0.078, 0.063, 1)
	_style_listening.corner_radius_top_left = 12
	_style_listening.corner_radius_top_right = 12
	_style_listening.corner_radius_bottom_left = 12
	_style_listening.corner_radius_bottom_right = 12
	_style_listening.shadow_color = Color(0.102, 0.078, 0.063, 1)
	_style_listening.shadow_size = 2
	_style_listening.shadow_offset = Vector2(0, 2)
	_style_listening.content_margin_left = 12
	_style_listening.content_margin_right = 12
	
# Busca los botones Key* en las dos columnas (ColMove y ColAttack)
func _discover_key_buttons() -> void:
	var page = get_node_or_null("PageControl")
	if page == null:
		push_warning("controls.gd: no se encontró PageControl")
		return
		
	for col_name in ["ColMove", "ColAttack"]:
		var col = page.get_node_or_null(col_name)
		if col == null:
			continue
		for row in col.get_children():
			if not row is HBoxContainer:
				continue
			for child in row.get_children():
				if child is Button and child.name.begins_with("Key"):
					var id: String = child.name.substr(3) #"keyUp" -> "Up"
					if id in ACTION_MAP:
						key_buttons[id] = child
						child.pressed.connect(_on_key_button_pressed.bind(id))
						
# Cargar los binds guardados en ConfiManager y los aplica al InputMap
func _load_saved_binds() -> void:
	var config_manager = get_node_or_null("/root/ConfigManager")
	if config_manager == null:
		return
		
	for id in ACTION_MAP:
		var action: String = ACTION_MAP[id]
		var saved_keycode: int = config_manager.get_setting("controls", action, -1)
		if saved_keycode >= 0:
			_apply_bind(action, saved_keycode)

# ─── Lógica de remapeo ──────────────────────────────────────────────────────
# Cuando se pulsa un botón KayCap entra en modo escuchando
func _on_key_button_pressed(id: String) -> void:
	if _listening_id == id:
		# Click de nuevo en el mismo para cancelar
		_cancel_listening()
		return
		
	# Si ya estábamos escuchando otro cancelar primero
	if _listening_id != "":
		_set_button_style(_listening_id, false)
	
	_listening_id = id
	_set_button_style(id, true)
	key_buttons[id].text = "..."
	
# Captura la siguente tecla pulsada mientras estamos en modo escucha
func _input(event: InputEvent) -> void:
	if _listening_id == "":
		return
	
	if not event is InputEventKey:
		return
	if not event.pressed:
		return
	
	# ESC cancela la reasignación
	if event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE:
		_cancel_listening()
		get_viewport().set_input_as_handled()
		return
		
	var keycode: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
	var action: String = ACTION_MAP[_listening_id]
	
	# Comprobar si la tecla ya está asignada a otra acción
	var conflict_id: String = _find_conflict(keycode, _listening_id)
	if conflict_id != "":
		# Intercambiar, la otra acción recibe la tecla que teníamos nosotros
		var my_old_keycode: int = _get_current_keycode(action)
		var other_action: String = ACTION_MAP[conflict_id]
		_apply_bind(other_action, my_old_keycode)
		_save_bind(other_action, my_old_keycode)
		_refresh_label(conflict_id)
		
	# Aplicamos el nuevo bin
	_apply_bind(action, keycode)
	_save_bind(action, keycode)
	
	# Restaurar el estado visual
	_set_button_style(_listening_id, false)
	_refresh_label(_listening_id)
	_listening_id = ""
	
	get_viewport().set_input_as_handled()
	
func _cancel_listening() -> void:
	if _listening_id == "":
		return
	_set_button_style(_listening_id, false)
	_refresh_label(_listening_id)
	_listening_id = ""
	
# ─── Helpers de InputMap ─────────────────────────────────────────────────────
# Reemplaza solo el evento de teclado de la acción consevando gamepads
func _apply_bind(action: String, keycode: int) -> void:
	if not InputMap.has_action(action):
		push_warning("controls.gd: acción '%s' no existe en InputMap" % action)
		return
		
	# Recogemos los evento que no son de teclado (joystick, etc) para conservarlos
	var non_key_events: Array[InputEvent] = []
	for ev in InputMap.action_get_events(action):
		if not ev is InputEventKey:
			non_key_events.append(ev)
	
	InputMap.action_erase_events(action)
	
	# Re-añadir los eventos de gamepad
	for ev in non_key_events:
		InputMap.action_add_event(action, ev)
		
	# Añadir el nuevo evento de teclado
	var new_ev := InputEventKey.new()
	new_ev.physical_keycode = keycode
	new_ev.device = -1
	InputMap.action_add_event(action, new_ev)
	
# Devuelve el physical_keycode actual del evento de teclado de una acción
func _get_current_keycode(action: String) -> int:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			return ev.physical_keycode if ev.physical_keycode != 0 else ev.keycode
	return -1
	
# Busca si el keycode ya está asignado a tora acción devuelve el id o ""
func _find_conflict(keycode: int, exclude_id: String) -> String:
	for id in ACTION_MAP:
		if id == exclude_id:
			continue
		var action: String = ACTION_MAP[id]
		var current: int = _get_current_keycode(action)
		if current == keycode:
			return id
	return ""
	
# Guarda el bind en ConfigManager
func _save_bind(action: String, keycode: int) -> void:
	var config_manager = get_node_or_null("/root/ConfiManager")
	if config_manager:
		config_manager.set_setting("controls", action, keycode)

# ─── UI ──────────────────────────────────────────────────────────────────────
# Convierte un keycode en texto legible para el botón
func _keycode_to_label(keycode: int) -> String:
	if keycode <= 0:
		return "-"
	
	# Casos especiales que queremos mostrar 
	match keycode:
		KEY_SPACE:
			return "SPACE"
		KEY_ENTER:
			return "ENTER"
		KEY_TAB:
			return "TAB"
		KEY_BACKSPACE:
			return "BKSP"
		KEY_DELETE:
			return "DEL"
		KEY_INSERT:
			return "INS"
		KEY_HOME:
			return "HOME"
		KEY_END:
			return "END"
		KEY_PAGEUP:
			return "PGUP"
		KEY_PAGEDOWN:
			return "PGDN"
		KEY_UP:
			return "UP"
		KEY_DOWN:
			return "DOWN"
		KEY_LEFT:
			return "LEFT"
		KEY_RIGHT:
			return "RIGHT"
		KEY_SHIFT:
			return "SHIFT"
		KEY_CTRL:
			return "CTRL"
		KEY_ALT:
			return "ALT"
		KEY_CAPSLOCK:
			return "CAPS"
	
	# Para letras y números OS.get_keycode_string funciona bien
	var label: String = OS.get_keycode_string(keycode)
	if label != "":
		return label.to_upper()
	
	return "?"

# Actualiza el texto de un botón KeyCap con la tecla actualmente asignada
func _refresh_label(id: String) -> void:
	if id not in key_buttons or id not in ACTION_MAP:
		return
	var action: String = ACTION_MAP[id]
	var keycode: int = _get_current_keycode(action)
	key_buttons[id].text = _keycode_to_label(keycode)
	
# Refresca todos los labels al iniciar
func _refresh_all_labels() -> void:
	for id in key_buttons:
		_refresh_label(id)

# Cambia el estilo visual de un KeyCap entre normal y "escuchando".
func _set_button_style(id: String, listening: bool) -> void:
	if id not in key_buttons:
		return
	var btn: Button = key_buttons[id]
	if listening:
		btn.add_theme_stylebox_override("normal", _style_listening)
		btn.add_theme_stylebox_override("hover", _style_listening)
		btn.add_theme_stylebox_override("pressed", _style_listening)
		btn.add_theme_stylebox_override("focus", _style_listening)
		btn.add_theme_color_override("font_color", Color(0.957, 0.918, 0.824, 1))  # cream
	else:
		btn.add_theme_stylebox_override("normal", _style_normal)
		btn.add_theme_stylebox_override("hover", _style_normal)
		btn.add_theme_stylebox_override("pressed", _style_normal)
		btn.add_theme_stylebox_override("focus", _style_normal)
		btn.add_theme_color_override("font_color", Color(0.102, 0.078, 0.063, 1))  # ink
		
