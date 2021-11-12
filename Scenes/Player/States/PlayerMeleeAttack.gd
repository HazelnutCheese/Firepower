extends PlayerBaseState

func physics_update(delta: float) -> void:
	if(get_tree().is_network_server()):
		var networkInputs = InputManager._getInputs(player._networkId)
		if(networkInputs["inGame_Attack1"]):
			state_machine.transition_to_sub("Light_1H_Sword_01")
		if(networkInputs["inGame_Attack2"]):
			state_machine.transition_to_sub("Heavy_1H_Slam")
