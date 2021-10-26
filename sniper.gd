extends Node2D


const NUM_LOCKON_SOUNDS := 4
const MAX_RAY_DISTANCE := 1000.0
export var sensor_distance := 128.0
export var hit_speed := 500.0
export var beam_color := Color(1.0, 0.0, 0.0, 1.0)
var collision_mask
var target: Node2D = null
var old_target_visible := false
var lockon_position: Vector2
onready var lockon_timer: Timer = $LockonTimer
onready var lockon_sound_timer: Timer = $LockonSoundTimer
onready var shoot_delay_timer: Timer = $ShootDelayTimer
onready var cooldown_timer: Timer = $CooldownTimer
onready var gun: Sprite = $Gun
onready var beam: Line2D = $Beam
onready var beam_fade_timer: Timer = $Beam/FadeTimer
onready var gravity: float = ProjectSettings.get("physics/2d/default_gravity")
onready var muzzle := $Gun/MuzzlePos
onready var lockon_sound := $LockonSound
onready var shoot_sound := $ShootSound


func _ready():
	# TODO: This doesn't seem to work. WAR'd by setting it in the editor to the
	#         maximum ever used value of sensor_distance.
	#$PlayerSensor/CollisionShape2D.shape.radius = sensor_distance
	#$PlayerSensor/CollisionShape2D.shape.call_deferred("set_radius", sensor_distance)
	#print("SENSOR RADIUS ", $PlayerSensor/CollisionShape2D.shape.radius)
	collision_mask = 0x1 | 0x2 # Ground and player
	beam.set_as_toplevel(true)
	beam.visible = false
	lockon_sound_timer.wait_time = lockon_timer.wait_time / NUM_LOCKON_SOUNDS


func _physics_process(delta):
	if not target:
		return
		
	if cooldown_timer.is_stopped():
		var target_visible := _is_target_visible()
		if target_visible and not old_target_visible:
			lockon_timer.start()
			lockon_sound_timer.start()
		elif old_target_visible and not target_visible:
			lockon_timer.stop()
			lockon_sound_timer.stop()
		old_target_visible = target_visible
		if target_visible and shoot_delay_timer.is_stopped():
			var target_pos = target.global_position
			gun.global_rotation = PI + gun.global_position.angle_to_point(target_pos)
		elif not shoot_delay_timer.is_stopped():
			gun.global_rotation = PI + gun.global_position.angle_to_point(lockon_position)

	if lockon_timer.is_stopped() and shoot_delay_timer.is_stopped():
		$Gun.frame = 0
	else:
		var progress := 1.0 - lockon_timer.time_left / lockon_timer.wait_time
		#*$Gun.frame = 1 + int(progress * ($Gun.hframes - 1))
		
	if beam.visible:
		var fade_progress := 1.0 - beam_fade_timer.time_left / beam_fade_timer.wait_time
		beam.default_color.a = 1.0 - fade_progress


func _raycast(src, dst) -> bool:
	var space_state = get_world_2d().direct_space_state
	return space_state.intersect_ray(src, dst, [], collision_mask)


func _is_target_visible() -> bool:
	var src := gun.global_position
	var dst := target.global_position
	if (dst - src).length_squared() > sensor_distance * sensor_distance:
		return false
	var result = _raycast(src, dst)
	return result and result.collider == target


func _on_PlayerSensor_body_entered(body):
	# This basically just permanently sets the target to the player when it
	# first sees it.
	if not target:
		target = body


func shoot():
	shoot_sound.play()
	lockon_timer.stop()
	#lockon_sound_timer.stop()
	cooldown_timer.start()
	old_target_visible = false # Reset the shooting cycle
	var src = muzzle.global_position
	var direction = (lockon_position - src).normalized()
	var result = _raycast(src, src + direction * MAX_RAY_DISTANCE)
	beam.default_color = beam_color
	beam.clear_points()
	beam.add_point(src)
	var end_point = direction * MAX_RAY_DISTANCE # In case of no ray collision
	if result:
		end_point = result.position
	beam.add_point(end_point)
	beam.visible = true
	beam_fade_timer.start()
	if result and result.collider == target:
		target._velocity += direction * hit_speed
		#target._velocity.x = -hit_speed
		if target.is_on_floor():
			#target.position.y -= 2
			# Force move upward to avoid ground friction removing all x velocity.
			target._velocity.y = -abs(target._velocity.y)
		# TODO: Consider doing this for bounce pads too, or using a non-hacky
		#         solution based on if the velocity exceeds the jump velocity.
		# Reset is_jumping to disable jump-cancelling (it's very confusing
		# otherwise).
		target.is_jumping = false


func _on_LockonTimer_timeout():
	#lockon_sound.play()
	# Predict target position after shoot delay, forcing the player to dodge.
	var dt := shoot_delay_timer.wait_time
	var a := Vector2(0.0, gravity if not target.is_on_floor() else 0.0)
	var v: Vector2 = target._velocity + 0.5 * a * dt
	v.y = min(v.y, target.max_fall_speed)
	lockon_position = (
		#target.global_position + target._velocity * dt + 0.5 * a * dt * dt)
		target.global_position + v * dt)
	shoot_delay_timer.start()
	lockon_sound_timer.stop()
	# HACK: This is required because lockon_sound_timer gets stopped before its
	#         final timeout gets called.
	lockon_sound.play()
	$Gun.frame += 1


func _on_FadeTimer_timeout():
	beam.visible = false


func _on_ShootDelayTimer_timeout():
	shoot()


func _on_LockonSoundTimer_timeout():
	lockon_sound.play()
	$Gun.frame += 1
