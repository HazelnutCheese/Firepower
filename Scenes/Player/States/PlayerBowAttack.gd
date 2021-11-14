extends PlayerBaseState

func physics_update(delta: float) -> void:
	if(get_tree().is_network_server()):
		var networkInputs = InputManager._getInputs(player._networkId)
		if(networkInputs["inGame_Attack1"]):
			state_machine.transition_to_sub("Bow_Light_01")
		if(networkInputs["inGame_Attack2"]):
			state_machine.transition_to_sub("Bow_Heavy_01")
