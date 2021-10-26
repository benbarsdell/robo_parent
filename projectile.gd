extends RigidBody2D

# Forced state variables, for syncing the physics engine.
var _reset := false
var _position: Vector2
var _linear_velocity: Vector2
var _rotation: float
var _angular_velocity: float
onready var hit_ground_sound := $HitGroundSound


func get_state() -> Dictionary:
	var state := {
		position = position,
		rotation = rotation,
		linear_velocity = linear_velocity,
		angular_velocity = angular_velocity,
	}
	return state

func _integrate_forces(state: Physics2DDirectBodyState):
	if _reset:
		state.transform = Transform2D(_rotation, _position)
		state.linear_velocity = _linear_velocity
		state.angular_velocity = _angular_velocity
		_reset = false

func set_state(state: Dictionary) -> void:
	position = state.position
	rotation = state.rotation
	linear_velocity = state.linear_velocity
	angular_velocity = state.angular_velocity
	_position = state.position
	_rotation = state.rotation
	_linear_velocity = state.linear_velocity
	_angular_velocity = state.angular_velocity
	_reset = true
	
	
func _physics_process(_delta):
	rotation = linear_velocity.angle()


func _on_Projectile_body_entered(body):
	if body.has_method("on_projectile_collision"):
		body.on_projectile_collision(self)
	else:
		if visible:
			hit_ground_sound.play()
			visible = false


func _on_HitGroundSound_finished():
	Globals.remove_node(self)
