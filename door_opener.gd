extends Area2D


export var door_path: NodePath
onready var door := get_node_or_null(door_path)


func _on_DoorOpener_body_entered(body):
	if door:
		door.open()
