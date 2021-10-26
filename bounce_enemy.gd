extends Actor


enum { MODE_IDLE, MODE_AGRO, MODE_DISABLED }
var _mode := MODE_IDLE
var _player
onready var ground_detectors := [$GroundDetectorLeft, $GroundDetectorRight]
onready var player_detect_sound := $PlayerDetectSound
onready var player_lost_sound := $PlayerLostSound


func _ready():
	var bounce := 0.9
	# Make projectiles (rigid bodies) bounce off.
	Physics2DServer.body_set_param($Bouncer.get_rid(), Physics2DServer.BODY_PARAM_BOUNCE, bounce)
	

func _physics_process(delta):
	if _mode == MODE_AGRO:
		# HACK: This is a WAR for a strange bug where the y velocity increases
		#         over time even though the position doesn't. It would cause the
		#         body to be stuck to the ground after some time, and then
		#         vanish completely after even more time. Given that these
		#         enemies don't need vertical motion, forcing it to zero is an
		#         easy workaround.
		_velocity.y = 0.0
		var player_vec: Vector2 = _player.global_position - global_position
		var direction_x := sign(player_vec.x)
		var direction := Vector2(direction_x, 0.0)
		if ground_detectors[int(direction_x == 1)].is_colliding():
			move(direction)
		#	print("BOUNCE ENEMY MOVE", direction, " ", position, " ", _velocity)
		$Sprite.flip_h = direction_x == -1


func _on_PlayerSensor_body_entered(body):
	print("_on_PlayerSensor_body_entered")
	player_detect_sound.play()
	# TODO: Can/should use a ray-cast to check for LOS to player?
	_player = body
	_set_mode(MODE_AGRO)


func _on_PlayerSensor_body_exited(body):
	print("_on_PlayerSensor_body_exited")
	player_lost_sound.play()
	_set_mode(MODE_IDLE)


func _set_mode(mode):
	_mode = mode
	# HACK TODO: This should be cleaned up.
	if _mode == MODE_IDLE:
		$Sprite.frame = 0
	elif _mode == MODE_AGRO:
		$Sprite.frame = 2
	elif _mode == MODE_DISABLED:
		$Sprite.frame = 4
