extends PlayerBaseState

func physics_update(delta: float) -> void:
	player._animationTree.set("parameters/Run_To_Fall/blend_amount", 1)
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
		
		var direction = input.rotated(Vector3.UP, player.rotation.y).normalized()#
		player._velocity = lerp(player._velocity, direction * player.MAX_AIR_MOVE_VELOCITY, delta * player.AIR_ACCEL)
		
		if(player.is_on_floor()):
			player._velocity = Vector3()
			if(isWalking):
				state_machine.transition_to("Walk")
			else:
				state_machine.transition_to("Idle")

func enter(_msg := {}) -> void:
	player._animationTree.set("parameters/Run_To_Fall/blend_amount", 1)

func exit(_msg := {}) -> void:
	if(get_tree().is_network_server()):
		InputManager._updateRemoteInput(player._networkId,"inGame_Jump", false)
	player._currentHealth -= 5
	player._animationTree.set("parameters/Fall_To_Land/active", true)
	player._animationTree.set("parameters/Run_To_Fall/blend_amount", 0)
