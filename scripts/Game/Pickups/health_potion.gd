extends Area2D

@export var heal_amount: float = 30.0
@export var destroy_on_pickup: bool = true

# Animación flotante opcional
@export var float_enabled: bool = true
@export var float_amplitude: float = 4.0
@export var float_speed: float = 2.0

var _base_y: float

func _ready() -> void:
	_base_y = position.y
	# Conectar la señal de colisión
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if float_enabled:
		position.y = _base_y + sin(Time.get_ticks_msec() / 1000.0 * float_speed) * float_amplitude

func _on_body_entered(body: Node2D) -> void:
	# Verificar que es un jugador (tiene PlayerModule con StatsModule)
	var player_module = body.get_node_or_null("PlayerModule")
	if player_module == null:
		return

	var stats = player_module.StatsModule
	if stats == null:
		return

	# No curar si ya tiene vida máxima
	if stats.health >= stats.maxHealth:
		return

	# Aplicar curación
	stats.health = min(stats.health + heal_amount, stats.maxHealth)

	# Feedback visual/sonoro (opcional)
	AudioManager.play_sfx("bonus")
	_play_pickup_effect()

	if destroy_on_pickup:
		queue_free()

func _play_pickup_effect() -> void:
	# Opción A: reproducir SFX directamente
	# Puedes usar el AudioManager que ya tienes en el proyecto
	# MusicManager o un AudioStreamPlayer local

	# Opción B: emitir señal para que otro sistema lo maneje
	# signal picked_up(heal_amount)

	pass
