class_name BTRevert, "res://addons/behavior_tree/icons/btrevert.svg"
extends BTDecorator

# Succeeds if the child fails and viceversa.

func _tick(delta: float, agent: Node, blackboard: Blackboard) -> bool:
	var result = bt_child.tick(delta, agent, blackboard)
	
	if result is GDScriptFunctionState:
		result = yield(result, "completed")
	
	if bt_child.succeeded():
		return fail()
	return succeed()

