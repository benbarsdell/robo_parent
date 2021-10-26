extends Control


var is_initializing := true


func _ready():
	$VBoxContainer/Buttons/NewGameButton.grab_focus()
	$VBoxContainer/VolumeControl/Sliders/EffectsVolumeSlider.value = AudioServer.get_bus_volume_db(2)
	$VBoxContainer/VolumeControl/Sliders/MusicVolumeSlider.value = AudioServer.get_bus_volume_db(1)
	$VBoxContainer/ShowTimerCheckbox.pressed = Globals.show_timer
	is_initializing = false


func _on_NewGameButton_pressed():
	get_tree().change_scene("res://main.tscn")


func _on_CreditsButton_pressed():
	get_tree().change_scene("res://credits.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_ShowTimerCheckbox_toggled(button_pressed):
	Globals.show_timer = button_pressed


func _on_EffectsVolumeSlider_value_changed(value):
	if is_initializing:
		return
	AudioServer.set_bus_volume_db(2, value)
	$ExampleSound.play()


func _on_MusicVolumeSlider_value_changed(value):
	if is_initializing:
		return
	AudioServer.set_bus_volume_db(1, value)
	$ExampleMusic.play()
	$ExampleMusicTimer.start()


func _on_ExampleMusicTimer_timeout():
	$ExampleMusic.stop()
