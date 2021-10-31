extends PlayerBaseState

const MOVE_ACCEL = 3.5
const TURN_SPEED = 2.5

func physics_update(delta: float) -> void:
	if(get_tree().is_network_server()):
		var networkInputs = InputManager._getInputs(player._networkId)

		var input = Vector3()
		if(networkInputs["inGame_MoveForward"]):
			input.z -= 1
#		if(networkInputs["inGame_MoveBackward"]):
#			input.z += 1
#		if(networkInputs["inGame_StrafeLeft"]):
#			input.x -= 1
#		if(networkInputs["inGame_StrafeRight"]):
#			input.x += 1
		
		var isWalking = not input.z == 0
		
		var maxTurnSpeed = 10.0
		player._rotate_player_process(maxTurnSpeed, delta)
		
		var direction = input.normalized().rotated(
			Vector3.UP, 
			deg2rad(player.rotation_degrees.y - 45))
		
		player._velocity = lerp(
			player._velocity, 
			direction * player.MAX_SPRINT_VELOCITY, 
			delta * MOVE_ACCEL)

		var vDirection = player._velocity.normalized().rotated(
			Vector3.UP, 
			-deg2rad(player.rotation_degrees.y - 45))

		player._animationTree.pset_unreliable(
			"parameters/Idle_To_Run/blend_amount", 
			1)

		player._animationTree.pset_unreliable(
			"parameters/Run_Blend/blend_position", 
			Vector2(vDirection.x, vDirection.z/2))

		if(networkInputs["inGame_Roll"]):
			state_machine.transition_to("Roll")
		elif(networkInputs["inGame_Attack1"]):
			state_machine.transition_to("MeleeAttack")
		elif(networkInputs["inGame_Jump"]):
			state_machine.transition_to("Jump")
		elif(not player.is_on_floor() and not player.is_on_wall()):
			state_machine.transition_to("Fall")
		elif(isWalking and not networkInputs["inGame_Sprint"]):
			state_machine.transition_to("Walk")
		elif(not isWalking):
			state_machine.transition_to("Idle")

func enter(_msg := {}) -> void:
	if(get_tree().is_network_server()):
		player._animationTree.pset("parameters/Run_To_Fall/blend_amount", 0)
