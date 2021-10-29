extends PlayerBaseState

const MOVE_DECEL = 6.0

func physics_update(delta: float) -> void:
	var animationBlendAmount = player._velocity.length() / player.MAX_SPRINT_VELOCITY
	player._animationTree.set("parameters/Idle_To_Run/blend_amount", animationBlendAmount)
	if(get_tree().is_network_server()):
		var networkInputs = InputManager._getInputs(player._networkId)

		var input = Vector3()
		if(networkInputs["inGame_MoveForward"]):
			input.z -= 1
		if(networkInputs["inGame_MoveBackward"]):
			input.z += 1
		if(networkInputs["inGame_StrafeLeft"]):
			input.x -= 1
		if(networkInputs["inGame_StrafeRight"]):
			input.x += 1
		
		var isWalking = not (input.x == 0 and input.z == 0)

		var direction = Vector3(1,1,1).rotated(Vector3.UP, deg2rad(networkInputs["cameraY"]))
		player._velocity = lerp(player._velocity, direction * 0, delta * MOVE_DECEL)
		
		if(networkInputs["inGame_Attack1"]):
			state_machine.transition_to("MeleeAttack")
		elif(networkInputs["inGame_Jump"]):
			state_machine.transition_to("Jump")
		elif(not player.is_on_floor()):
			state_machine.transition_to("Fall")
		elif(isWalking):
			state_machine.transition_to("Walk")
