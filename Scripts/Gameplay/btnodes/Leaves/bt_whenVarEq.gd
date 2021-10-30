class_name BTWhenVarEq
extends BTLeaf

export(String) var variableName: String
export(String) var expectedValue: String

func _tick(delta: float, agent: Node, blackboard: Blackboard) -> bool:
	var variableValue = agent.get(variableName)
	if(str(variableValue) == expectedValue):
		return succeed()
	else:
		return fail()
