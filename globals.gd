extends Node


const settings_filename := "user://robo_parent_settings.json"
var completion_time_str := "--:--:--.--"
var show_timer := false
enum { DIFFICULTY_EASY = 0, DIFFICULTY_NORMAL = 1, DIFFICULTY_HARD = 2, DIFFICULTY_BRUTAL = 3 }
var difficulty := DIFFICULTY_NORMAL
var cheat_mode := false
var cheat_mode_used := false


# **TODO: It turns out this isn't actually needed, as we can always find nodes
#           by instance_id even if they're not in the tree. So at most all we
#           need here are helpers to remove/restore the parent relationship
#           (the storage of the parent info could be done in the frame_state
#            Dictionary instead of here).
#           Really the only thing needed is a helper to wrap
#             node.get_parent().remove_child(node) (for which a singleton may be
#             overkill).
# Nodes that have been removed from the scene (key is the instance id).
var _removed_nodes := {}


func reset_settings():
	# TODO: Can't actually reset the settings without closing the app after this.
	#         Need to store the defaults and restore them explicitly.
	var dir := Directory.new()
	if dir.file_exists(settings_filename):
		dir.remove(settings_filename)


func save_settings():
	var settings_file := File.new()
	settings_file.open(settings_filename, File.WRITE)
	var settings = {
		show_timer = show_timer,
		difficulty = difficulty,
		cheat_mode = cheat_mode,
		fullscreen = OS.window_fullscreen,
		music_volume_db = AudioServer.get_bus_volume_db(1),
		effects_volume_db = AudioServer.get_bus_volume_db(2),
		
	}
	settings_file.store_line(to_json(settings))
	settings_file.close()
	
	
func load_settings():
	var settings_file := File.new()
	if not settings_file.file_exists(settings_filename):
		return
	settings_file.open(settings_filename, File.READ)
	var settings = parse_json(settings_file.get_line())
	if "show_timer" in settings:
		show_timer = settings.show_timer
	if "difficulty" in settings:
		difficulty = settings.difficulty
	if "cheat_mode" in settings:
		cheat_mode = settings.cheat_mode
	if "fullscreen" in settings:
		OS.window_fullscreen = settings.fullscreen
	if "music_volume_db" in settings:
		AudioServer.set_bus_volume_db(1, settings.music_volume_db)
	if "effects_volume_db" in settings:
		AudioServer.set_bus_volume_db(2, settings.effects_volume_db)


func _ready():
	# WAR for multiple monitors fullscreen issue.
	OS.window_fullscreen = true
	load_settings()


func remove_node(node: Node):
	_removed_nodes[node.get_instance_id()] = {
		parent = node.get_parent(),
		node = node,
	}
	node.get_parent().remove_child(node)


func restore_node(instance_id: int) -> Node:
	var node_info = _removed_nodes[instance_id]
	var _erased = _removed_nodes.erase(instance_id)
	node_info.parent.add_child(node_info.node)
	return node_info.node
