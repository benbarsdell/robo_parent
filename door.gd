extends StaticBody2D


signal open
signal close
export var is_open := false
onready var shapes := [$CollisionShape2D3]#[$CollisionShape2D, $CollisionShape2D2]
onready var animation_player := $AnimationPlayer
onready var open_sound := $OpenSound
onready var close_sound := $CloseSound


func _ready():
	if is_open:
		is_open = false
		open(false)


func toggle():
	if is_open:
		close()
	else:
		open()


func open(animate := true):
	if is_open:
		return
	if animate:
		open_sound.play()
	emit_signal("open")
	# TODO: Ideally, change shape sizes to match animation.
	for shape_ in shapes:
		var shape: CollisionShape2D = shape_
		shape.set_deferred("disabled", true)
	is_open = true
	if animate:
		animation_player.play("open")
	else:
		$Sprite.frame = 7
	
	
func close(animate := true):
	if not is_open:
		return
	if animate:
		close_sound.play()
	emit_signal("close")
	# TODO: Ideally, don't enable shapes until open animation finishes.
	for shape_ in shapes:
		var shape: CollisionShape2D = shape_
		shape.set_deferred("disabled", false)
	is_open = false
	if animate:
		animation_player.play_backwards("open")
	else:
		$Sprite.frame = 0
