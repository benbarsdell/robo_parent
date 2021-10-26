extends KinematicBody2D


signal returned_balloon # The win signal!
var balloon = null
var grab_count := 0
var player: Player


func on_grab_balloon(balloon_):
	#print("CHILD GRAB BALLOON")
	balloon = balloon_
	grab_count += 1
	if grab_count == 2:
		$AnimationPlayer.stop()
		$Sprite.frame_coords = Vector2(0, 0) # Look forward again
		$AnimationPlayer.play("jump")
		emit_signal("returned_balloon")
	
	
func on_release_balloon(balloon_):
	balloon = null
	
	
func _physics_process(delta):
	if player and grab_count == 2:
		$Sprite.flip_h = player.global_position.x < global_position.x


func _on_Door_open():
	$LookUpDelayTimer.start()
	# Turn to face the door.
	$Sprite.flip_h = true
	if balloon:
		balloon.release(self)


func _on_SadDelayTimer_timeout():
	$AnimationPlayer.play("cry")


func _on_PlayerSensor_body_entered(body):
	player = body


func _on_LookUpDelayTimer_timeout():
	$Sprite.frame_coords = Vector2(0, 1) # Look up
	$SadDelayTimer.start()
