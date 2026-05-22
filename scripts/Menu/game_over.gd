extends CanvasLayer

# Menú de Game Over — se muestra cuando el jugador muere

signal retry_pressed
signal exit_pressed

var is_active: bool = false

func _ready():
	visible = false
	_set_children_visible(false)
	process_mode = Node.PROCESS_MODE_ALWAYS


func show_game_over():
	is_active = true
	get_tree().paused = true
	visible = true
	_set_children_visible(true)
	
func _set_children_visible(state: bool):
	$ColorRect.visible = state
	$Label.visible = state
	$RetryButton.visible = state
	$ExitButton.visible = state


func _on_retry_button_pressed() -> void:
	is_active = false
	get_tree().paused = false
	retry_pressed.emit()


func _on_exit_button_pressed() -> void:
	is_active = false
	get_tree().paused = false
	exit_pressed.emit()
