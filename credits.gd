extends Control


# TODO: This isn't needed any more, try to clean it up.
var initial_text: String
onready var credits_text = $CreditsText


func _ready():
	initial_text = credits_text.bbcode_text
	update_text()
	$AnimationPlayer.play("scroll")

func update_text():
	credits_text.bbcode_text = (
		"[center]" +
		"Robo-Parent\nof the Year\n\n\n" +
		"Completion time: " + Globals.completion_time_str +
		initial_text +
		"[/center]")


func _on_AnimationPlayer_animation_finished(_anim_name):
	get_tree().change_scene("res://main_menu.tscn")


func _unhandled_key_input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene("res://main_menu.tscn")
