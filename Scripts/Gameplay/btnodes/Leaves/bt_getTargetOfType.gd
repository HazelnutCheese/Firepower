class_name BTGetTargetOfGroup, "res://addons/behavior_tree/icons/btleaf.svg"
extends BTLeaf

# Finds a node which is the targeted scene type
export(String) var group_name: String
export(String) var result_key: String

func _tick(delta: float, agent: Node, blackboard: Blackboard) -> bool:
	var currentNode = agent
	var target = null
	
	if(blackboard.get_data(result_key) != null):
		return succeed()
	
	var group = get_tree().get_nodes_in_group(group_name)
	var groupSize = group.size()
	if(groupSize == 0):
		return fail()
	
	var targetIndex = randi() % group.size()
	blackboard.set_data(result_key, group[targetIndex])
	return succeed()
