class_name Actor
extends KinematicBody2D

# Both the Player and Enemy inherit this scene as they have shared behaviours
# such as speed and are affected by gravity.

const FLOOR_NORMAL := Vector2.UP
const FLOOR_DETECT_DISTANCE = 10.0
export var max_run_speed := 42.0
export var default_max_fall_speed := 400.0
export var max_fall_speed: float = default_max_fall_speed
export var run_acceleration := 10.0
export var air_acceleration := 4.0
export var jump_speed := 150.0
export var friction := 0.85
export var air_resistance := 0.01
var _velocity := Vector2.ZERO
#onready var platform_detector := $PlatformDetector
onready var default_gravity: float = ProjectSettings.get("physics/2d/default_gravity")
onready var gravity := default_gravity


func get_state() -> Dictionary:
	return {
		position = position,
		rotation = rotation,
		velocity = _velocity,
	}


func set_state(state: Dictionary) -> void:
	position = state.position
	rotation = state.rotation
	_velocity = state.velocity


# _physics_process is called after the inherited _physics_process function.
# This allows the Player and Enemy scenes to be affected by gravity.
func _physics_process(delta):
	_velocity.y += gravity * delta


func move(direction: Vector2):
	var accel := run_acceleration if is_on_floor() else air_acceleration
	var delta_vel_x := direction.x * accel
	# Don't allow accelerating if we are already at or over the speed limit.
	if delta_vel_x != 0.0 and sign(delta_vel_x) == sign(_velocity.x):
		delta_vel_x = sign(delta_vel_x) * min(abs(delta_vel_x), max(max_run_speed - abs(_velocity.x), 0.0))
	_velocity.x += delta_vel_x
		
	if direction.y < 0.0:
		_velocity.y = direction.y * jump_speed
	if direction.y > 0.0:
		_velocity.y = 0.0 # Cancel jump
	
	var snap_vector := Vector2.ZERO
	if direction.y == 0.0:
		snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE
	var is_on_platform: bool = false;#platform_detector.is_colliding()
	#_velocity = move_and_slide_with_snap(
	#	_velocity, snap_vector, FLOOR_NORMAL, not is_on_platform, 4, 0.9, false)
	_velocity = move_and_slide(
		_velocity, FLOOR_NORMAL, not is_on_platform, 4, 0.9, false)
		
	# Note: Important to add friction _after_ calling move_and_slide so that
	#         external velocities can be applied without them being reduced
	#         due to friction until the actor has been confirmed to be on
	#         the floor.
	#if direction.x == 0.0:
	if direction.x == 0.0 or sign(direction.x) != sign(_velocity.x):
		if is_on_floor():
			_velocity.x *= 1.0 - friction
		else:
			_velocity.x *= 1.0 - air_resistance
		#if abs(_velocity.x) <= 0.1 * max_run_speed:
		#	_velocity.x = 0.0
		
	_velocity.y = min(_velocity.y, max_fall_speed)
