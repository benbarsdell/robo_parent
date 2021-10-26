extends AnimatedSprite


onready var pickup_sound := $PickupSound


func _on_PlayerSensor_body_entered(player: Player):
	pickup_sound.play()
	visible = false
	player.gun.visible = true


func _on_PickupSound_finished():
	queue_free()
