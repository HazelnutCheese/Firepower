class_name BTMeleeAttack
extends BTLeaf

export(String) var actualTarget: String

func _tick(delta: float, agent: Node, blackboard: Blackboard) -> bool:
	if(agent._isInHitFrames):
		return succeed()
	
	var kinematicAgent = agent as KinematicEntity
	kinematicAgent._velocity = Vector3()
	
	var actualTargetSpatial = null
	if actualTarget:
		actualTargetSpatial = blackboard.get_data(actualTarget) as Spatial
	
	var comboFrame = blackboard.get_data("comboFrame")
	
	if(comboFrame == 0):
		if actualTarget:	
			kinematicAgent.look_at(actualTargetSpatial.translation, Vector3.UP)
			kinematicAgent.rotate_object_local(Vector3.UP, PI)
		agent.animationTree.pset("parameters/To_MeleeAttack1/active", true)
		blackboard.set_data("comboFrame", 1)
		return fail()	
	elif(agent.animationTree.get("parameters/To_MeleeAttack1/active")):
		return fail()
		
	if(comboFrame == 1):
		if actualTarget:
			kinematicAgent.look_at(actualTargetSpatial.translation, Vector3.UP)
			kinematicAgent.rotate_object_local(Vector3.UP, PI)
		agent.animationTree.pset("parameters/To_MeleeAttack2/active", true)
		blackboard.set_data("comboFrame", 2)
		return fail()
	elif(agent.animationTree.get("parameters/To_MeleeAttack2/active")):
		return fail()

	blackboard.set_data("comboFrame", 0)
	return succeed()
