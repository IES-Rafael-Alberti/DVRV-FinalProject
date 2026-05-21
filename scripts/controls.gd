extends MarginContainer

## ─── Mapeo acción → InputMap ────────────────────────────────────────────────
## Claves = sufijos de los nodos de la UI (Up, Right, B1, B2…).
## Valores = nombres de acción en project.godot.
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

## Acciones de movimiento usan ejes de joystick; ataques usan botones.
## Mapa: id → { axis, axis_value } para movimiento (JoypadMotion).
const GAMEPAD_MOVE_DEFAULTS: Dictionary = {
	"Up":    { "axis": JOY_AXIS_LEFT_Y,  "value": -1.0 },
	"Right": { "axis": JOY_AXIS_LEFT_X,  "value":  1.0 },
	"Down":  { "axis": JOY_AXIS_LEFT_Y,  "value":  1.0 },
	"Left":  { "axis": JOY_AXIS_LEFT_X,  "value": -1.0 },
}

## Mapa: id → button_index para ataques (JoypadButton).
const GAMEPAD_ATTACK_DEFAULTS: Dictionary = {
	"B1": JOY_BUTTON_X,
	"B2": JOY_BUTTON_B,
	"B3": JOY_BUTTON_A,
	"B4": JOY_BUTTON_Y,
}

## IDs que son movimiento (se remapean con ejes/D-Pad).
const MOVE_IDS: Array = ["Up", "Right", "Down", "Left"]
## IDs que son ataques (se remapean con botones).
const ATTACK_IDS: Array = ["B1", "B2", "B3", "B4"]

# ─── Nodos UI ────────────────────────────────────────────────────────────────
var _btn_keyboard: Button
var _btn_gamepad: Button
var _page_keyboard: Control
var _page_gamepad: Control

## Botones Key* (teclado) y Pad* (mando) indexados por id.
var key_buttons: Dictionary = {}
var pad_buttons: Dictionary = {}

## Estilos para KeyCap / PadCap.
var _style_normal: StyleBoxFlat
var _style_listening: StyleBoxFlat

## Toggle activo y estilo.
var _style_toggle_active: StyleBoxFlat
var _style_toggle_inactive: StyleBoxFlat

## Estado de escucha.
var _listening_id: String = ""
var _listening_mode: String = ""  # "keyboard" o "gamepad"


func _ready() -> void:
	_build_styles()
	_setup_sub_toggles()
	_discover_key_buttons()
	_discover_pad_buttons()
	_load_saved_binds()
	_refresh_all_labels()
	_switch_page("keyboard")


# ══════════════════════════════════════════════════════════════════════════════
# INICIALIZACIÓN
# ══════════════════════════════════════════════════════════════════════════════

func _build_styles() -> void:
	# ── KeyCap normal ──
	_style_normal = StyleBoxFlat.new()
	_style_normal.bg_color = Color(0.957, 0.918, 0.824, 1)
	for prop in ["border_width_left", "border_width_top", "border_width_right", "border_width_bottom"]:
		_style_normal.set(prop, 4)
	_style_normal.border_color = Color(0.102, 0.078, 0.063, 1)
	for prop in ["corner_radius_top_left", "corner_radius_top_right", "corner_radius_bottom_left", "corner_radius_bottom_right"]:
		_style_normal.set(prop, 12)
	_style_normal.shadow_color = Color(0.102, 0.078, 0.063, 1)
	_style_normal.shadow_size = 5
	_style_normal.shadow_offset = Vector2(0, 5)
	_style_normal.content_margin_left = 12
	_style_normal.content_margin_right = 12

	# ── KeyCap listening (rose) ──
	_style_listening = _style_normal.duplicate()
	_style_listening.bg_color = Color(0.769, 0.416, 0.416, 1)
	_style_listening.shadow_size = 2
	_style_listening.shadow_offset = Vector2(0, 2)

	# ── Sub-toggle activo (panel_dk, "hundido") ──
	_style_toggle_active = StyleBoxFlat.new()
	_style_toggle_active.bg_color = Color(0.176, 0.259, 0.125, 1)  # panel_dk
	for prop in ["border_width_left", "border_width_top", "border_width_right", "border_width_bottom"]:
		_style_toggle_active.set(prop, 4)
	_style_toggle_active.border_color = Color(0.102, 0.078, 0.063, 1)
	for prop in ["corner_radius_top_left", "corner_radius_top_right", "corner_radius_bottom_left", "corner_radius_bottom_right"]:
		_style_toggle_active.set(prop, 12)
	_style_toggle_active.shadow_color = Color(0.102, 0.078, 0.063, 1)
	_style_toggle_active.shadow_size = 2
	_style_toggle_active.shadow_offset = Vector2(0, 2)
	_style_toggle_active.content_margin_left = 14
	_style_toggle_active.content_margin_right = 14
	_style_toggle_active.content_margin_top = 6
	_style_toggle_active.content_margin_bottom = 6

	# ── Sub-toggle inactivo (wood_dk, levantado) ──
	_style_toggle_inactive = _style_toggle_active.duplicate()
	_style_toggle_inactive.bg_color = Color(0.227, 0.157, 0.094, 1)  # wood_dk
	_style_toggle_inactive.shadow_size = 5
	_style_toggle_inactive.shadow_offset = Vector2(0, 5)


func _setup_sub_toggles() -> void:
	var root = get_node_or_null("ControlsRoot")
	if root == null:
		push_warning("controls.gd: no se encontró ControlsRoot")
		return

	var bar = root.get_node_or_null("SubToggleBar")
	_btn_keyboard = bar.get_node_or_null("BtnKeyboard") if bar else null
	_btn_gamepad = bar.get_node_or_null("BtnGamepad") if bar else null
	_page_keyboard = root.get_node_or_null("PageControl")
	_page_gamepad = root.get_node_or_null("PageGamepad")

	if _btn_keyboard:
		_btn_keyboard.pressed.connect(_on_toggle_keyboard)
	if _btn_gamepad:
		_btn_gamepad.pressed.connect(_on_toggle_gamepad)


func _discover_key_buttons() -> void:
	var page = get_node_or_null("ControlsRoot/PageControl")
	if page == null:
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
					var id: String = child.name.substr(3)
					if id in ACTION_MAP:
						key_buttons[id] = child
						child.pressed.connect(_on_key_button_pressed.bind(id))


func _discover_pad_buttons() -> void:
	var page = get_node_or_null("ControlsRoot/PageGamepad")
	if page == null:
		return
	for col_name in ["ColMoveGP", "ColAttackGP"]:
		var col = page.get_node_or_null(col_name)
		if col == null:
			continue
		for row in col.get_children():
			if not row is HBoxContainer:
				continue
			for child in row.get_children():
				if child is Button and child.name.begins_with("Pad"):
					var id: String = child.name.substr(3)
					if id in ACTION_MAP:
						pad_buttons[id] = child
						child.pressed.connect(_on_pad_button_pressed.bind(id))


func _load_saved_binds() -> void:
	var cm = get_node_or_null("/root/ConfigManager")
	if cm == null:
		return
	# Teclado
	for id in ACTION_MAP:
		var action: String = ACTION_MAP[id]
		var saved: int = cm.get_setting("controls", action, -1)
		if saved >= 0:
			_apply_keyboard_bind(action, saved)
	# Gamepad botones
	for id in ATTACK_IDS:
		var action: String = ACTION_MAP[id]
		var saved: int = cm.get_setting("controls_gp", action, -1)
		if saved >= 0:
			_apply_gamepad_button_bind(action, saved)
	# Gamepad ejes — guardamos como "axis:value" (ej. "1:-1")
	for id in MOVE_IDS:
		var action: String = ACTION_MAP[id]
		var saved: String = cm.get_setting("controls_gp", action, "")
		if saved != "":
			var parts = saved.split(":")
			if parts.size() == 2:
				_apply_gamepad_axis_bind(action, int(parts[0]), float(parts[1]))


# ══════════════════════════════════════════════════════════════════════════════
# SUB-TOGGLE
# ══════════════════════════════════════════════════════════════════════════════

func _on_toggle_keyboard() -> void:
	_cancel_listening()
	_switch_page("keyboard")

func _on_toggle_gamepad() -> void:
	_cancel_listening()
	_switch_page("gamepad")

func _switch_page(mode: String) -> void:
	var is_kb = (mode == "keyboard")
	if _page_keyboard:
		_page_keyboard.visible = is_kb
	if _page_gamepad:
		_page_gamepad.visible = not is_kb
	_update_toggle_styles(is_kb)

func _update_toggle_styles(keyboard_active: bool) -> void:
	if _btn_keyboard:
		AudioManager.play_sfx("btn")
		var s = _style_toggle_active if keyboard_active else _style_toggle_inactive
		_btn_keyboard.add_theme_stylebox_override("normal", s)
		_btn_keyboard.add_theme_stylebox_override("hover", s)
		_btn_keyboard.add_theme_stylebox_override("pressed", s)
		_btn_keyboard.add_theme_stylebox_override("focus", s)
		_btn_keyboard.add_theme_color_override("font_color",
			Color(0.941, 0.784, 0.314, 1) if keyboard_active else Color(0.957, 0.918, 0.824, 1))
	if _btn_gamepad:
		AudioManager.play_sfx("btn")
		var s = _style_toggle_active if not keyboard_active else _style_toggle_inactive
		_btn_gamepad.add_theme_stylebox_override("normal", s)
		_btn_gamepad.add_theme_stylebox_override("hover", s)
		_btn_gamepad.add_theme_stylebox_override("pressed", s)
		_btn_gamepad.add_theme_stylebox_override("focus", s)
		_btn_gamepad.add_theme_color_override("font_color",
			Color(0.941, 0.784, 0.314, 1) if not keyboard_active else Color(0.957, 0.918, 0.824, 1))


# ══════════════════════════════════════════════════════════════════════════════
# ESCUCHA — TECLADO
# ══════════════════════════════════════════════════════════════════════════════

func _on_key_button_pressed(id: String) -> void:
	AudioManager.play_sfx("btn")
	if _listening_id == id and _listening_mode == "keyboard":
		_cancel_listening()
		return
	_cancel_listening()
	_listening_id = id
	_listening_mode = "keyboard"
	_set_button_style(key_buttons, id, true)
	key_buttons[id].text = "..."


# ══════════════════════════════════════════════════════════════════════════════
# ESCUCHA — GAMEPAD
# ══════════════════════════════════════════════════════════════════════════════

func _on_pad_button_pressed(id: String) -> void:
	AudioManager.play_sfx("btn")
	if _listening_id == id and _listening_mode == "gamepad":
		_cancel_listening()
		return
	_cancel_listening()
	_listening_id = id
	_listening_mode = "gamepad"
	_set_button_style(pad_buttons, id, true)
	pad_buttons[id].text = "..."


# ══════════════════════════════════════════════════════════════════════════════
# INPUT — captura de teclas y botones de mando
# ══════════════════════════════════════════════════════════════════════════════

func _input(event: InputEvent) -> void:
	if _listening_id == "":
		return

	# ── Modo teclado: captura InputEventKey ──
	if _listening_mode == "keyboard" and event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE:
			_cancel_listening()
			get_viewport().set_input_as_handled()
			return

		var keycode: int = event.physical_keycode if event.physical_keycode != 0 else event.keycode
		var action: String = ACTION_MAP[_listening_id]

		# Swap si hay conflicto
		var conflict: String = _find_keyboard_conflict(keycode, _listening_id)
		if conflict != "":
			var my_old: int = _get_current_keycode(action)
			var other_action: String = ACTION_MAP[conflict]
			_apply_keyboard_bind(other_action, my_old)
			_save_keyboard_bind(other_action, my_old)
			_refresh_key_label(conflict)

		_apply_keyboard_bind(action, keycode)
		_save_keyboard_bind(action, keycode)
		_set_button_style(key_buttons, _listening_id, false)
		_refresh_key_label(_listening_id)
		_listening_id = ""
		_listening_mode = ""
		get_viewport().set_input_as_handled()
		return

	# ── Modo gamepad: captura JoypadButton o JoypadMotion ──
	if _listening_mode == "gamepad":
		# ESC en teclado cancela también en modo gamepad
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE:
				_cancel_listening()
				get_viewport().set_input_as_handled()
				return

		# Botón de mando
		if event is InputEventJoypadButton and event.pressed:
			var btn_idx: int = event.button_index
			var action: String = ACTION_MAP[_listening_id]

			# Swap si hay conflicto entre ataques
			if _listening_id in ATTACK_IDS:
				var conflict: String = _find_gamepad_button_conflict(btn_idx, _listening_id)
				if conflict != "":
					var my_old: int = _get_current_joypad_button(ACTION_MAP[conflict])
					# Asignar mi viejo al conflicto (puede ser -1 si era un eje antes)
					if my_old >= 0:
						var other_action: String = ACTION_MAP[conflict]
						_apply_gamepad_button_bind(other_action, _get_current_joypad_button(action))
						_save_gamepad_button_bind(other_action, _get_current_joypad_button(action))
						_refresh_pad_label(conflict)

			_apply_gamepad_button_bind(action, btn_idx)
			_save_gamepad_button_bind(action, btn_idx)
			_set_button_style(pad_buttons, _listening_id, false)
			_refresh_pad_label(_listening_id)
			_listening_id = ""
			_listening_mode = ""
			get_viewport().set_input_as_handled()
			return

		# Eje de mando (stick / D-Pad)
		if event is InputEventJoypadMotion and abs(event.axis_value) > 0.6:
			var axis: int = event.axis
			var axis_val: float = sign(event.axis_value)
			var action: String = ACTION_MAP[_listening_id]

			if _listening_id in MOVE_IDS:
				# Swap si conflicto entre movimientos
				var conflict: String = _find_gamepad_axis_conflict(axis, axis_val, _listening_id)
				if conflict != "":
					var my_old = _get_current_joypad_axis(action)
					if my_old != null:
						var other_action: String = ACTION_MAP[conflict]
						_apply_gamepad_axis_bind(other_action, my_old["axis"], my_old["value"])
						_save_gamepad_axis_bind(other_action, my_old["axis"], my_old["value"])
						_refresh_pad_label(conflict)

			_apply_gamepad_axis_bind(action, axis, axis_val)
			_save_gamepad_axis_bind(action, axis, axis_val)
			_set_button_style(pad_buttons, _listening_id, false)
			_refresh_pad_label(_listening_id)
			_listening_id = ""
			_listening_mode = ""
			get_viewport().set_input_as_handled()
			return


func _cancel_listening() -> void:
	if _listening_id == "":
		return
	if _listening_mode == "keyboard" and _listening_id in key_buttons:
		_set_button_style(key_buttons, _listening_id, false)
		_refresh_key_label(_listening_id)
	elif _listening_mode == "gamepad" and _listening_id in pad_buttons:
		_set_button_style(pad_buttons, _listening_id, false)
		_refresh_pad_label(_listening_id)
	_listening_id = ""
	_listening_mode = ""


# ══════════════════════════════════════════════════════════════════════════════
# APPLY / GET — TECLADO
# ══════════════════════════════════════════════════════════════════════════════

func _apply_keyboard_bind(action: String, keycode: int) -> void:
	if not InputMap.has_action(action):
		return
	var keep: Array[InputEvent] = []
	for ev in InputMap.action_get_events(action):
		if not ev is InputEventKey:
			keep.append(ev)
	InputMap.action_erase_events(action)
	for ev in keep:
		InputMap.action_add_event(action, ev)
	var new_ev := InputEventKey.new()
	new_ev.physical_keycode = keycode
	new_ev.device = -1
	InputMap.action_add_event(action, new_ev)

func _get_current_keycode(action: String) -> int:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventKey:
			return ev.physical_keycode if ev.physical_keycode != 0 else ev.keycode
	return -1

func _find_keyboard_conflict(keycode: int, exclude_id: String) -> String:
	for id in ACTION_MAP:
		if id == exclude_id:
			continue
		if _get_current_keycode(ACTION_MAP[id]) == keycode:
			return id
	return ""

func _save_keyboard_bind(action: String, keycode: int) -> void:
	var cm = get_node_or_null("/root/ConfigManager")
	if cm:
		cm.set_setting("controls", action, keycode)


# ══════════════════════════════════════════════════════════════════════════════
# APPLY / GET — GAMEPAD BOTONES
# ══════════════════════════════════════════════════════════════════════════════

func _apply_gamepad_button_bind(action: String, btn_idx: int) -> void:
	if not InputMap.has_action(action):
		return
	var keep: Array[InputEvent] = []
	for ev in InputMap.action_get_events(action):
		if not ev is InputEventJoypadButton:
			keep.append(ev)
	InputMap.action_erase_events(action)
	for ev in keep:
		InputMap.action_add_event(action, ev)
	var new_ev := InputEventJoypadButton.new()
	new_ev.button_index = btn_idx
	new_ev.device = -1
	InputMap.action_add_event(action, new_ev)

func _get_current_joypad_button(action: String) -> int:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventJoypadButton:
			return ev.button_index
	return -1

func _find_gamepad_button_conflict(btn_idx: int, exclude_id: String) -> String:
	for id in ATTACK_IDS:
		if id == exclude_id:
			continue
		if _get_current_joypad_button(ACTION_MAP[id]) == btn_idx:
			return id
	return ""

func _save_gamepad_button_bind(action: String, btn_idx: int) -> void:
	var cm = get_node_or_null("/root/ConfigManager")
	if cm:
		cm.set_setting("controls_gp", action, btn_idx)


# ══════════════════════════════════════════════════════════════════════════════
# APPLY / GET — GAMEPAD EJES (movimiento)
# ══════════════════════════════════════════════════════════════════════════════

func _apply_gamepad_axis_bind(action: String, axis: int, axis_val: float) -> void:
	if not InputMap.has_action(action):
		return
	var keep: Array[InputEvent] = []
	for ev in InputMap.action_get_events(action):
		if not ev is InputEventJoypadMotion:
			keep.append(ev)
	InputMap.action_erase_events(action)
	for ev in keep:
		InputMap.action_add_event(action, ev)
	var new_ev := InputEventJoypadMotion.new()
	new_ev.axis = axis
	new_ev.axis_value = axis_val
	new_ev.device = -1
	InputMap.action_add_event(action, new_ev)

func _get_current_joypad_axis(action: String) -> Variant:
	for ev in InputMap.action_get_events(action):
		if ev is InputEventJoypadMotion:
			return { "axis": ev.axis, "value": ev.axis_value }
	return null

func _find_gamepad_axis_conflict(axis: int, axis_val: float, exclude_id: String) -> String:
	for id in MOVE_IDS:
		if id == exclude_id:
			continue
		var cur = _get_current_joypad_axis(ACTION_MAP[id])
		if cur != null and cur["axis"] == axis and sign(cur["value"]) == sign(axis_val):
			return id
	return ""

func _save_gamepad_axis_bind(action: String, axis: int, axis_val: float) -> void:
	var cm = get_node_or_null("/root/ConfigManager")
	if cm:
		cm.set_setting("controls_gp", action, "%d:%s" % [axis, axis_val])


# ══════════════════════════════════════════════════════════════════════════════
# UI — LABELS
# ══════════════════════════════════════════════════════════════════════════════

func _keycode_to_label(keycode: int) -> String:
	if keycode <= 0:
		return "—"
	match keycode:
		KEY_SPACE: return "SPACE"
		KEY_ENTER: return "ENTER"
		KEY_TAB: return "TAB"
		KEY_BACKSPACE: return "BKSP"
		KEY_DELETE: return "DEL"
		KEY_INSERT: return "INS"
		KEY_HOME: return "HOME"
		KEY_END: return "END"
		KEY_PAGEUP: return "PGUP"
		KEY_PAGEDOWN: return "PGDN"
		KEY_UP: return "UP"
		KEY_DOWN: return "DOWN"
		KEY_LEFT: return "LEFT"
		KEY_RIGHT: return "RIGHT"
		KEY_SHIFT: return "SHIFT"
		KEY_CTRL: return "CTRL"
		KEY_ALT: return "ALT"
		KEY_CAPSLOCK: return "CAPS"
	var label: String = OS.get_keycode_string(keycode)
	if label != "":
		return label.to_upper()
	return "?"

## Nombres legibles para los botones del mando (layout Xbox).
func _joypad_button_label(btn_idx: int) -> String:
	match btn_idx:
		JOY_BUTTON_A: return "A"
		JOY_BUTTON_B: return "B"
		JOY_BUTTON_X: return "X"
		JOY_BUTTON_Y: return "Y"
		JOY_BUTTON_LEFT_SHOULDER: return "LB"
		JOY_BUTTON_RIGHT_SHOULDER: return "RB"
		JOY_BUTTON_LEFT_STICK: return "L3"
		JOY_BUTTON_RIGHT_STICK: return "R3"
		JOY_BUTTON_BACK: return "SELECT"
		JOY_BUTTON_START: return "START"
		JOY_BUTTON_DPAD_UP: return "D-PAD ↑"
		JOY_BUTTON_DPAD_DOWN: return "D-PAD ↓"
		JOY_BUTTON_DPAD_LEFT: return "D-PAD ←"
		JOY_BUTTON_DPAD_RIGHT: return "D-PAD →"
	return "BTN %d" % btn_idx

## Nombres legibles para ejes del mando.
func _joypad_axis_label(axis: int, axis_val: float) -> String:
	var stick: String
	match axis:
		JOY_AXIS_LEFT_X:
			stick = "L.STICK " + ("→" if axis_val > 0 else "←")
		JOY_AXIS_LEFT_Y:
			stick = "L.STICK " + ("↓" if axis_val > 0 else "↑")
		JOY_AXIS_RIGHT_X:
			stick = "R.STICK " + ("→" if axis_val > 0 else "←")
		JOY_AXIS_RIGHT_Y:
			stick = "R.STICK " + ("↓" if axis_val > 0 else "↑")
		JOY_AXIS_TRIGGER_LEFT:
			stick = "LT"
		JOY_AXIS_TRIGGER_RIGHT:
			stick = "RT"
		_:
			stick = "AXIS %d %s" % [axis, "+" if axis_val > 0 else "-"]
	return stick

func _refresh_key_label(id: String) -> void:
	if id not in key_buttons or id not in ACTION_MAP:
		return
	key_buttons[id].text = _keycode_to_label(_get_current_keycode(ACTION_MAP[id]))

func _refresh_pad_label(id: String) -> void:
	if id not in pad_buttons or id not in ACTION_MAP:
		return
	var action: String = ACTION_MAP[id]
	# Primero intenta botón (para ataques)
	var btn: int = _get_current_joypad_button(action)
	if btn >= 0:
		pad_buttons[id].text = _joypad_button_label(btn)
		return
	# Luego intenta eje (para movimiento)
	var ax = _get_current_joypad_axis(action)
	if ax != null:
		pad_buttons[id].text = _joypad_axis_label(ax["axis"], ax["value"])
		return
	pad_buttons[id].text = "—"

func _refresh_all_labels() -> void:
	for id in key_buttons:
		_refresh_key_label(id)
	for id in pad_buttons:
		_refresh_pad_label(id)


# ══════════════════════════════════════════════════════════════════════════════
# UI — ESTILOS
# ══════════════════════════════════════════════════════════════════════════════

func _set_button_style(buttons: Dictionary, id: String, listening: bool) -> void:
	if id not in buttons:
		return
	var btn: Button = buttons[id]
	var style = _style_listening if listening else _style_normal
	for s_name in ["normal", "hover", "pressed", "focus"]:
		btn.add_theme_stylebox_override(s_name, style)
	btn.add_theme_color_override("font_color",
		Color(0.957, 0.918, 0.824, 1) if listening else Color(0.102, 0.078, 0.063, 1))
