class_name BTParallel, "res://addons/behavior_tree/icons/btparallel.svg"
extends BTComposite

# Executes each child. doesn't wait for completion, always succeeds.

func _tick(delta: float, agent: Node, blackboard: Blackboard) -> bool:
	for c in children:
		bt_child = c
		bt_child.tick(delta, agent, blackboard)
	
	return succeed()

