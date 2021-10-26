extends KinematicBody2D


const Projectile = preload("res://projectile.tscn")
export var speed := 500.0#200.0
onready var muzzle := $MuzzlePos
onready var shoot_sound := $ShootSound
onready var cooldown_timer := $CooldownTimer


func shoot(velocity := Vector2.ZERO):
	if not cooldown_timer.is_stopped():
		return
	cooldown_timer.start()
	var projectile = Projectile.instance()
	projectile.global_position = muzzle.global_position
	var direction = (muzzle.global_position - global_position).normalized()
	projectile.linear_velocity = velocity + speed * direction
	projectile.set_as_toplevel(true)
	add_child(projectile)
	shoot_sound.play()
	
