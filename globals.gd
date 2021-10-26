extends Node


var completion_time_str := "--:--:--.--"
var show_timer := false


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
