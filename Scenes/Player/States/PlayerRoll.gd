extends PlayerBaseState

func physics_update(delta: float) -> void:
	player._rotate_player_process(6.0, delta)
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
		
		if(player._animationTree.get("parameters/To_Roll/active")):
			return

		if(isWalking):
			state_machine.transition_to("Walk")
		else:
			state_machine.transition_to("Idle")

func enter(_msg := {}) -> void:
	if(get_tree().is_network_server()):
		player._animationTree.pset("parameters/To_Roll/active", true)
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
		player._set_rotation_to_camera()
		var direction = input.normalized().rotated(
			Vector3.UP, 
			deg2rad(player.rotation_degrees.y - 45))
		player._velocity = direction.normalized() * 10
		var playerDir = direction + player.translation
		player.look_at(playerDir, Vector3.UP)
		player.rotation_degrees.y += 45
#		player.look_at(playerDir, Vector3.UP)
		
		
	player._rotateWithPlayer = false
	

func exit(_msg := {}) -> void:
	player._rotateWithPlayer = true
