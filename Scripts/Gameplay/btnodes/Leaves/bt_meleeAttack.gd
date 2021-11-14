class_name BTMeleeAttack
extends BTLeaf

export(String) var actualTarget: String
export(float) var impulse_x: float = 5.5
export(float) var impulse_y: float = 5.5
export(float) var impulse_z: float = 5.5

var weaponHitbox = null
var weaponCollision = null
var hitList = []

func _ready():
	yield(owner, "ready")
	weaponHitbox = owner._weaponHitbox
	weaponCollision = owner._weaponCollision

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
		hitList.clear()
		if actualTarget:	
			kinematicAgent.look_at(actualTargetSpatial.translation, Vector3.UP)
			kinematicAgent.rotate_object_local(Vector3.UP, PI)
		agent.animationTree.pset("parameters/To_MeleeAttack1/active", true)
		blackboard.set_data("comboFrame", 1)
		return fail()	
	elif(agent.animationTree.get("parameters/To_MeleeAttack1/active")):
		if(not weaponHitbox.monitoring):
			return fail()
		var overlappingBodies = weaponHitbox.get_overlapping_bodies()
		for body in overlappingBodies:
			_weaponHitbox_entered1(body)
		return fail()
		
#	if(comboFrame == 1):
#		if actualTarget:
#			kinematicAgent.look_at(actualTargetSpatial.translation, Vector3.UP)
#			kinematicAgent.rotate_object_local(Vector3.UP, PI)
#		agent.animationTree.pset("parameters/To_MeleeAttack2/active", true)
#		blackboard.set_data("comboFrame", 2)
#		return fail()
#	elif(agent.animationTree.get("parameters/To_MeleeAttack2/active")):
#		return fail()

	blackboard.set_data("comboFrame", 0)
	return succeed()
	
func _weaponHitbox_entered1(body):
	if(body != null and body is Player):
		var name = body.get_name()
		if((not hitList.has(name)) and body.has_method("_hurt")):
			body._hurt(owner, 0, "crushing")
			var impulseDirection = owner.translation.direction_to(body.translation)
			impulseDirection.y = 1
			var impulse = impulseDirection * Vector3(impulse_x, impulse_y, impulse_z)
			body._impulse(owner, impulse)
			hitList.append(name)
