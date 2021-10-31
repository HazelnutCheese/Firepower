extends PlayerBaseState

const MOVE_ACCEL = 2.0

func physics_update(delta: float) -> void:
	var animationBlendAmount = player._velocity.length() / player.MAX_SPRINT_VELOCITY
	player._animationTree.pset_unreliable(
		"parameters/Idle_To_Run/blend_amount", 
		animationBlendAmount)
	
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
		
		var maxMoveVelocity = player.MAX_MOVE_VELOCITY
		if(networkInputs["inGame_Sprint"]):
			maxMoveVelocity = player.MAX_SPRINT_VELOCITY
		
		var direction = input.normalized().rotated(Vector3.UP, deg2rad(networkInputs["cameraY"]))
#		player._velocity = lerp(player._velocity, direction * maxMoveVelocity, delta * MOVE_ACCEL)
		player._velocity = direction.normalized() * maxMoveVelocity

		if(networkInputs["inGame_Attack1"]):
			state_machine.transition_to("MeleeAttack")
		elif(networkInputs["inGame_Jump"]):
			state_machine.transition_to("Jump")
		elif(not player.is_on_floor() and not player.is_on_wall()):
			state_machine.transition_to("Fall")
		elif(not isWalking):
			state_machine.transition_to("Idle")

func enter(_msg := {}) -> void:
	if(get_tree().is_network_server()):
		player._animationTree.pset("parameters/Run_To_Fall/blend_amount", 0)
