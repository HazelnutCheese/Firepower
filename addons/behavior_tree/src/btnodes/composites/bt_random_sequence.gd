class_name BTRandomSequence, "res://addons/behavior_tree/icons/btrndsequence.svg"
extends BTSequence

# Just like a BTSequence, but the children are executed in random order.


func _pre_tick(delta: float, agent: Node, blackboard: Blackboard) -> void:
	randomize()
	children.shuffle()
