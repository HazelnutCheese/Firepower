class_name BTIsDistanceFromTarget
extends BTLeaf

export(String) var targetKey: String
export(int, "leq", "geq") var modifier
export(float) var distance: float

func _tick(delta: float, agent: Node, blackboard: Blackboard) -> bool:
	var agentTranslation = (agent as Spatial).translation
	var targetTranslation = (blackboard.get_data(targetKey) as Spatial).translation
	var distanceFrom = agentTranslation.distance_to(targetTranslation)
	
	if(modifier == 0 and distanceFrom <= distance):
		return succeed()
	elif(modifier == 1 and distanceFrom >= distance):
		return succeed()
	else:
		return fail()
