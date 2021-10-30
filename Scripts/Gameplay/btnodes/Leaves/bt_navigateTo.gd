class_name BTNavigateTo, "res://addons/behavior_tree/icons/btleaf.svg"
extends BTLeaf

# Navigates to the translation of the targetKey spatial
export(String) var targetKey: String
export(String) var resultKey: String

func _tick(delta: float, agent: Node, blackboard: Blackboard) -> bool:
	var agentSpatial = agent as Spatial
	var targetSpatial = blackboard.get_data(targetKey) as Spatial
	var navigation = get_navigation_ancestor(agent)
	var path = []
	path = navigation.get_simple_path(
		agentSpatial.translation, 
		targetSpatial.translation, 
		true)
	
	blackboard.set_data(resultKey, path)
	return succeed()

func get_navigation_ancestor(agent):
	var currentNode = agent
	var rootNode = get_tree().get_root()
	while(true):
		currentNode = currentNode.get_parent()
		if(currentNode is Navigation):
			return currentNode
		elif(currentNode == rootNode):
			assert(false, "Must be a descendant of a Navigation node")
