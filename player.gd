extends Actor
class_name Player

export var max_jump_count := 2 # 2 => double-jump
var is_jumping := false
var jump_count := 0
var balloon = null
var can_jump := false
#var can_jump := true # HACK TESTING
onready var gun := $Gun
onready var foot := $FootPos
onready var ignore_ground_sensor: RayCast2D = $IgnoreGroundSensor
onready var jump_sound := $JumpSound
onready var double_jump_sound := $DoubleJumpSound
onready var hit_ground_sound := $HitGroundSound


func get_state() -> Dictionary:
	var state = .get_state()
	state.gun_rotation = gun.rotation
	return state


func set_state(state: Dictionary) -> void:
	.set_state(state)
	gun.rotation = state.gun_rotation


func on_grab_balloon(balloon_):
	balloon = balloon_
	gun.visible = false
	

func on_release_balloon(balloon_):
	gun.visible = true


# Called when the node enters the scene tree for the first time.
func _ready():
	gun.visible = false
	pass # Replace with function body.


func _physics_process(_delta):
	var direction := _get_direction()
	
	var was_on_floor := is_on_floor()
	move(direction)
	# TODO: This seems to have too much delay to work well.
	#if is_on_floor() and not was_on_floor:
	#	hit_ground_sound.play()
	
	for i in get_slide_count():
		var collision := get_slide_collision(i)
		if collision.collider.has_method("on_player_collision"):
			collision.collider.on_player_collision(self, collision.normal)
		#if collision.collider is TileMap:
		#	hit_ground_sound.play()
		
	var mouse_pos := get_global_mouse_position()
	var looking_left = mouse_pos.x < global_position.x
	
	if direction.x != 0.0 and is_on_floor():
		var anim := "run_boots" if can_jump else "run"
		$AnimatedSprite.play(anim, (direction.x == -1) != looking_left)
	else:
		var anim := "idle_boots" if can_jump else "idle"
		$AnimatedSprite.animation = anim
		$AnimatedSprite.playing = false
		#$AnimatedSprite.play("idle")
	
	gun.global_rotation = PI + gun.global_position.angle_to_point(mouse_pos)
	$Sprite.flip_h = looking_left
	$AnimatedSprite.flip_h = looking_left
	$Gun/Sprite.flip_v = looking_left


func _get_direction() -> Vector2:
	if _velocity.y > 0:
		is_jumping = false
	var cancelled_jump := is_jumping and Input.is_action_just_released("ui_up")
	var is_on_ground := is_on_floor() and not ignore_ground_sensor.is_colliding()
	#var jumped := is_on_floor() and Input.is_action_pressed("ui_up")
	if is_on_ground:
		jump_count = 0
	var jumped := (
		can_jump and
		Input.is_action_just_pressed("ui_up") and
		(is_on_ground or (jump_count > 0 and jump_count < max_jump_count)))
	if jumped:
		is_jumping = true
		if jump_count == 0:
			jump_sound.play()
		else:
			double_jump_sound.play()
		jump_count += 1
		#print(jump_count)
	var x = (
		Input.get_action_strength("ui_right") -
		Input.get_action_strength("ui_left"))
	var y = -1 if jumped else 1 if cancelled_jump else 0
	## HACK TESTING
	#if Input.is_action_pressed("ui_down"):
	#	y = -1
	return Vector2(x, y)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if gun.visible:
				gun.shoot()
			elif balloon:
				balloon.release(self)


#func _on_EnableJumpSensor_body_entered(body):
#	can_jump = true


func _on_Child_returned_balloon():
	# Don't need gun any more.
	gun.visible = false


func _on_BootsPickup_boots_pickup():
	can_jump = true
