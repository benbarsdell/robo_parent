extends Node


var recorded_frames = []
var num_ticks := 0
var completion_num_ticks := 0


func _record_state():
	var frame_state := {}
	for node in get_tree().get_nodes_in_group("recordable"):
		frame_state[node.get_instance_id()] = {
			state = node.get_state(),
		}
	recorded_frames.append(frame_state)


func _restore_state():
	if recorded_frames.empty():
		return
	var frame_state = recorded_frames.pop_back()
	for node_instance_id in frame_state:
		var node_info: Dictionary = frame_state[node_instance_id]
		var node := instance_from_id(node_instance_id)
		if not node:
			print("NODE NOT FOUND: ", node_instance_id)
		if not node.get_parent():
			Globals.restore_node(node_instance_id)
			
		node.set_state(node_info.state)
	
	for node in get_tree().get_nodes_in_group("recordable"):
		if not (node.get_instance_id() in frame_state):
			Globals.remove_node(node)


func _set_recordable_physics_processing(enabled: bool):
	for node in get_tree().get_nodes_in_group("recordable"):
		node.set_physics_process(enabled)
		

func current_playtime_ms() -> int:
	return int(round(num_ticks * get_physics_process_delta_time() * 1000))


func get_time_str(time_ms: int):
	var rem := time_ms
	var ms := rem % (60 * 1000)
	rem /= 60 * 1000
	var m := rem % 60
	rem /= 60
	var h := rem
	return "%02d:%02d:%06.3f" % [h, m, float(ms) / 1000.0]
	

func _process_rewind():
	if Input.is_action_pressed("rewind"):
		_restore_state()
	else:
		_record_state()
	# Disable physics processing of recordable nodes while replaying.
	if Input.is_action_just_pressed("rewind"):
		_set_recordable_physics_processing(false)
	elif Input.is_action_just_released("rewind"):
		_set_recordable_physics_processing(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	num_ticks += 1
	if not completion_num_ticks:
		$OverlayLayer/TimeLabel.text = get_time_str(current_playtime_ms())
	$OverlayLayer/TimeLabel.visible = Globals.show_timer
	
	#_process_rewind()


#func _unhandled_key_input(event):
#	if event.is_action_pressed("ui_cancel"):
#		get_tree().quit()


func _on_Child_returned_balloon():
	completion_num_ticks = num_ticks
	Globals.completion_time_str = get_time_str(current_playtime_ms())
	$OverlayLayer/TimeLabel.text = Globals.completion_time_str
	$OverlayLayer/AnimationPlayer.play("fade_out")


func _on_AnimationPlayer_animation_finished(anim_name):
	get_tree().change_scene("res://credits.tscn")
