class_name BTWalkTo, "res://addons/behavior_tree/icons/btleaf.svg"
extends BTLeaf

# Walks each node in the path of targetKey
export(String) var pathKey: String
export(String) var actualTarget: String
export(float) var stopAtRange: float = 0.0
export(float) var avoid_distance: = 20.0
export(float) var step_size: = 8.0
export(float) var look_acceleration: = 4.0
export var separation_force: = 0.05

func _tick(delta: float, agent: Node, blackboard: Blackboard) -> bool:
	var path = blackboard.get_data(pathKey) as Array
	var kinematicBody = agent as KinematicEntity
	var actualTargetSpatial = null
	if actualTarget:
		actualTargetSpatial = blackboard.get_data(actualTarget) as Spatial
	
	if(path.size() == 0):
		return succeed()
	
	var finalPath = path[path.size() - 1]
	var distanceToFinalPath = kinematicBody.translation.distance_to(finalPath)
	if(distanceToFinalPath < stopAtRange):
		return succeed()
	
	if(actualTargetSpatial != null):
		var distanceToActualTarget = kinematicBody.translation.distance_to(actualTargetSpatial.translation)
		if(distanceToActualTarget < stopAtRange):
			return succeed()
			
	var distanceToPath = kinematicBody.translation.distance_to(path[0])
	while(distanceToPath < step_size/10):
		path.remove(0)
		if(path.empty()):
			return succeed()
		distanceToPath = kinematicBody.translation.distance_to(path[0])

	var destination = path[0]
	var aimFor = kinematicBody.translation.direction_to(destination)
	var lookAt = aimFor
	
	# Flocking
	if(avoid_distance > 0):
		var fellowAi = get_fellow_ai(agent)
		var avoid_vector: = Vector3()
		for f in fellowAi:
			var neighbor_pos: Vector3 = f.translation
			var d = agent.translation.distance_to(neighbor_pos)
			avoid_vector -= neighbor_pos.direction_to(agent.translation).normalized() * (avoid_distance/d * separation_force)
		lookAt = aimFor - avoid_vector
	
	kinematicBody.rotation.y = lerp_angle(
		kinematicBody.rotation.y, 
		atan2(aimFor.x, aimFor.z), 
		look_acceleration * delta)
	
	var stepVelocity = (lookAt).normalized() * step_size	
	kinematicBody._velocity.x = stepVelocity.x
	kinematicBody._velocity.z = stepVelocity.z
		
	return fail()

func get_fellow_ai(agent):
	var currentNode = agent
	var rootNode = get_tree().get_root()
	var listOfFellowAi = []
	while(currentNode != rootNode):
		currentNode = currentNode.get_parent()
		var children = currentNode.get_children()
		for child in children:
			if(child is TrainingDummy and child != agent):
				listOfFellowAi.append(child)
	return listOfFellowAi

func move_with_avoidance(agent, destination):
	pass
