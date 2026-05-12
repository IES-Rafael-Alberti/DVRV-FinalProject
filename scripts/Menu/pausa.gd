extends CanvasLayer



func _physics_process(delta):
	if Input.is_action_just_pressed("Pause"):
		_toggle_pause()

func _toggle_pause():
	var paused = not get_tree().paused
	get_tree().paused = paused
	$ColorRect.visible = paused
	$Label.visible = paused
	$ExitButton.visible = paused
	$ContinueButton.visible = paused
	$RetryButton.visible = paused



func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_continue_button_pressed() -> void:
	_toggle_pause()


func _on_retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
