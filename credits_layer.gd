extends CanvasLayer


var initial_text: String
var completion_time_str := "--:--:--.---"
onready var credits_text = $CreditsText


func _ready():
	initial_text = credits_text.bbcode_text
	update_text()


func set_completion_time_str(time_str: String):
	completion_time_str = time_str
	update_text()


func update_text():
	credits_text.bbcode_text = (
		"[center]" +
		"Robo-Parent\nof the Year\n\n\n" +
		"Completion time: " + completion_time_str +
		initial_text +
		"[/center]")
