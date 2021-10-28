extends Control


func _on_Button_pressed():
	queue_free()
	
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		queue_free()
