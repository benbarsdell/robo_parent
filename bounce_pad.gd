extends StaticBody2D


export var bounce_speed := 300.0
onready var bounce_sound := $BounceSound


func _ready():
	$AnimationPlayer.play("idle")


func _on_PlayerSensor_body_entered(body: Actor):
	#body._velocity.y = -bounce_speed
	var normal := -Vector2(cos(rotation + 0.5 * PI), sin(rotation + 0.5 * PI))
	body._velocity = (
		body._velocity.project(normal.tangent()) +
		normal * bounce_speed)
	bounce_sound.play()
