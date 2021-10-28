extends Control


const ControlsMenu = preload("res://controls_menu.tscn")
var is_initializing := true


func _ready():
	$VBoxContainer/Buttons/NewGameButton.grab_focus()
	$VBoxContainer/VolumeControl/Sliders/EffectsVolumeSlider.value = AudioServer.get_bus_volume_db(2)
	$VBoxContainer/VolumeControl/Sliders/MusicVolumeSlider.value = AudioServer.get_bus_volume_db(1)
	$VBoxContainer/HBoxContainer/ShowTimerCheckbox.pressed = Globals.show_timer
	$VBoxContainer/Difficulty/DifficultyMenu.selected = Globals.difficulty
	$VBoxContainer/HBoxContainer/FullscreenCheckbox.pressed = OS.window_fullscreen
	$VBoxContainer/Cheats/CheatModeCheckbox.pressed = Globals.cheat_mode
	is_initializing = false


func _on_NewGameButton_pressed():
	get_tree().change_scene("res://main.tscn")


func _on_CreditsButton_pressed():
	get_tree().change_scene("res://credits.tscn")


func _on_QuitButton_pressed():
	get_tree().quit()


func _on_ShowTimerCheckbox_toggled(button_pressed):
	Globals.show_timer = button_pressed
	Globals.save_settings()


func _on_EffectsVolumeSlider_value_changed(value):
	if is_initializing:
		return
	AudioServer.set_bus_volume_db(2, value)
	Globals.save_settings()
	$ExampleSound.play()


func _on_MusicVolumeSlider_value_changed(value):
	if is_initializing:
		return
	AudioServer.set_bus_volume_db(1, value)
	Globals.save_settings()
	$ExampleMusic.play()
	$ExampleMusicTimer.start()


func _on_ExampleMusicTimer_timeout():
	$ExampleMusic.stop()


func _on_DifficultyMenu_item_selected(index):
	Globals.difficulty = index
	Globals.save_settings()


func _on_CheatModeCheckbox_toggled(button_pressed):
	Globals.cheat_mode = button_pressed
	Globals.save_settings()


func _on_FullscreenCheckbox_toggled(button_pressed):
	OS.window_fullscreen = button_pressed
	Globals.save_settings()


func _on_ControlsButton_pressed():
	var controls_menu := ControlsMenu.instance()
	add_child(controls_menu)
