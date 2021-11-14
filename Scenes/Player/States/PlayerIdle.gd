extends PlayerBaseState

const MOVE_DECEL = 6.0

func physics_update(delta: float) -> void:
	player._rotate_player_process(6.0, delta)
	
	var animationBlendAmount = player._velocity.length() / player.MAX_SPRINT_VELOCITY
	player._animationTree.set(
		"parameters/Idle_To_Run/blend_amount", 
		animationBlendAmount)
	
	if(get_tree().is_network_server()):
		var networkInputs = InputManager._getInputs(player._networkId)

		var input = player._get_inputVector(networkInputs)
		
		var isWalking = not (input.x == 0 and input.z == 0)

		if(networkInputs["inGame_Roll"]):
			state_machine.transition_to("Roll")
		elif(networkInputs["inGame_Attack1"] or networkInputs["inGame_Attack2"]):
			state_machine.transition_to("MeleeAttack")
		elif(networkInputs["inGame_Jump"]):
			state_machine.transition_to("Jump")
		elif(not player.is_on_floor()):
			state_machine.transition_to("Fall")
		elif(isWalking):
			state_machine.transition_to("Walk")

func enter(_msg := {}) -> void:
	player._animationTree.set("parameters/Run_To_Fall/blend_amount", 0)
