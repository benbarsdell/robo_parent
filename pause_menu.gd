extends Control


var is_initializing := true


func _ready():
	$VBoxContainer/Buttons/ContinueButton.grab_focus()
	$VBoxContainer/VolumeControl/Sliders/EffectsSlider.value = AudioServer.get_bus_volume_db(2)
	$VBoxContainer/VolumeControl/Sliders/MusicSlider.value = AudioServer.get_bus_volume_db(1)
	$VBoxContainer/ShowTimerCheckbox.pressed = Globals.show_timer
	is_initializing = false


func _toggle_pause():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	if visible:
		$VBoxContainer/Buttons/ContinueButton.grab_focus()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()


func _on_RestartButton_pressed():
	_toggle_pause()
	get_tree().reload_current_scene()


func _on_ExitButton_pressed():
	_toggle_pause()
	get_tree().change_scene("res://main_menu.tscn")
	
	
func _on_EffectsSlider_value_changed(value):
	if is_initializing:
		return
	AudioServer.set_bus_volume_db(2, value)
	$ExampleSound.play()


func _on_MusicSlider_value_changed(value):
	if is_initializing:
		return
	AudioServer.set_bus_volume_db(1, value)


func _on_ShowTimerCheckbox_toggled(button_pressed):
	Globals.show_timer = button_pressed


func _on_ContinueButton_pressed():
	_toggle_pause()
