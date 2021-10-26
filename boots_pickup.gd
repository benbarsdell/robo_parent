extends Node2D


signal boots_pickup


func _on_EnableJumpSensor_body_entered(body):
	emit_signal("boots_pickup")
	visible = false
