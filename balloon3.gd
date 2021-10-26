extends RigidBody2D


const NUM_STRING_PIECES := 8
const STRING_PIECE_LENGTH := 1.5
const GRAB_FORCE := 25.0
var string_pieces := []
var holders := []
var max_hold_velocity := 450.0
onready var balloon: RigidBody2D = $Balloon
onready var balloon_shape: CollisionShape2D = $Balloon/CollisionShape2D
onready var string_length: float = balloon.position.length()


func _ready():
	$StringLine.clear_points()
	$StringLine.add_point(Vector2.ZERO)
	for i in range(NUM_STRING_PIECES):
		var string_piece: RigidBody2D = get_node("StringPiece" + str(i))
		string_pieces.append(string_piece)
		$StringLine.add_point(string_piece.position)
		string_piece.mass = 0.01
		string_piece.gravity_scale = 0.1
		string_piece.linear_damp = 1.75


func _physics_process(delta):
	for i in range(NUM_STRING_PIECES):
		$StringLine.points[1 + i] = string_pieces[i].position
		
	# Emulate the balloon pulling the player up.
	var cur_string_length := balloon.position.length()
	
	if not holders.empty():
		var player = holders[0]
		var has_velocity = player.get("_velocity") != null
		if cur_string_length >= 2.0 * string_length or (
			has_velocity and player._velocity.length_squared() > max_hold_velocity * max_hold_velocity):
			release(player)
		else:
			# Add a spring-like force to connect the string to the player.
			# Note: I tried using pin and spring joints, but I couldn't get them
			#         to do what I wanted.
			var between = player.global_position - global_position
			apply_central_impulse(between * GRAB_FORCE * delta)


func grab(player):
	if player in holders:
		return
	holders.append(player)
	if holders.size() > 1:
		return
	$SadMusic.stop()
	$HappyMusic.play()
	if player.has_method("on_grab_balloon"):
		player.on_grab_balloon(self)
	## TODO: This holders.size() is hacky. Should really update the next holder
	#          when the current holder releases.
	if player.get("max_fall_speed") != null:
		player.max_fall_speed = 25.0
	

func release(holder):
	if holders.empty():
		return
	if holder != holders[0]:
		return # Another node is actually holding it
	var player = holders.pop_front()
	if player.has_method("on_release_balloon"):
		player.on_release_balloon(self)
	if player.get("max_fall_speed") != null:
		player.max_fall_speed = player.default_max_fall_speed
	if holders.empty():
		$HappyMusic.stop()
		$SadMusic.play()
	else:
		# Next in queue grabs it.
		player = holders[0]
		if not $StringPiece3/PlayerSensor.overlaps_body(player):
			# No longer in contact.
			holders.pop_front()
			$HappyMusic.stop()
			$SadMusic.play()
			return
		if player.has_method("on_grab_balloon"):
			player.on_grab_balloon(self)
		if player.get("max_fall_speed") != null:
			player.max_fall_speed = 25.0


func _on_PlayerSensor_body_entered(player_):
	grab(player_)
