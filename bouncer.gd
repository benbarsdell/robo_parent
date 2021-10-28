extends KinematicBody2D


export var player_hit_speed := 300.0
onready var player_hit_sound = $PlayerHitSound
onready var projectile_hit_sound = $ProjectileHitSound


func on_player_collision(player: Player, normal: Vector2):
	normal = (player.foot.global_position - global_position).normalized()
	player._velocity = normal * player_hit_speed
	player_hit_sound.play()


func on_projectile_collision(projectile: RigidBody2D):
	# TODO: It's a pain not being able to access things in BounceEnemy here.
	# TODO: Consider making BounceEnemies destructable, but only when they are
	#         in agro mode. Should require ~2 shots to disable them (and they
	#         should come back to life after ~10 secs).
	projectile_hit_sound.play()
	#print("PROJECTILE COLLISION ", projectile.name)
