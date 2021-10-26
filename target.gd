extends StaticBody2D


signal activate
signal deactivate
export var timeout_secs := 5.0
# TODO: Rename to "target" or similar (held off for fear of breaking everything).
export var toggleable_path: NodePath
export var activate_method := "toggle"
export var deactivate_method := "toggle"
var toggleable: Node
onready var timer: Timer = $Timer
onready var hit_sound = $HitSound


func _ready():
	timer.wait_time = timeout_secs
	if not toggleable_path.is_empty():
		toggleable = get_node(toggleable_path)
	else:
		toggleable = null


func _physics_process(delta):
	if not timer.is_stopped():
		var progress := 1.0 - timer.time_left / timer.wait_time
		$Sprite.frame = 1 + int(progress * ($Sprite.hframes - 1))


func _on_ProjectileSensor_body_entered(body):
	Globals.remove_node(body)
	if timer.is_stopped():
		timer.start()
		emit_signal("activate")
		if toggleable:
			if activate_method:
				toggleable.call(activate_method)
		hit_sound.play()


func _on_Timer_timeout():
	emit_signal("deactivate")
	if toggleable:
		#toggleable.toggle()
		if deactivate_method:
			toggleable.call(deactivate_method)
	$Sprite.frame = 0
