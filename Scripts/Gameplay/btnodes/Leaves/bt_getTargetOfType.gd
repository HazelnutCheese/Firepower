class_name BTGetTargetOfType, "res://addons/behavior_tree/icons/btleaf.svg"
extends BTLeaf

# Finds a node which is the targeted scene type
export(String, FILE, "*.tscn,*.scn") var targetType: String
export(String) var resultKey: String

func _tick(delta: float, agent: Node, blackboard: Blackboard) -> bool:
	var currentNode = agent
	var target = null
	
	if(blackboard.get_data(resultKey) != null):
		return succeed()
	
	while(target == null):
		currentNode = currentNode.get_parent()
		if(currentNode == get_tree().get_root()):
			return fail()
		var children = currentNode.get_children()
		for child in children:
			if(child == agent):
				continue
			var fileName = child.filename
			if(fileName == targetType):
				blackboard.set_data(resultKey, child)
				return succeed()	
	return fail()
