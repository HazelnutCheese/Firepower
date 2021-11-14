extends PlayerBaseState

const MOVE_ACCEL = 7.0

func physics_update(delta: float) -> void:
	player._rotate_player_process(10.0, delta)
	
	var vDirection = player._velocity.normalized().rotated(
		Vector3.UP, 
		-player.rotation.y)
	
	var animationBlendAmount = player._velocity.length() / player.MAX_MOVE_VELOCITY
	player._animationTree.set(
		"parameters/Idle_To_Run/blend_amount", 
		animationBlendAmount)

	player._animationTree.set(
		"parameters/Run_Blend/blend_position", 
		Vector2(vDirection.x, -vDirection.z/2))
	
	if(get_tree().is_network_server()):
		var networkInputs = InputManager._getInputs(player._networkId)

		var input = player._get_inputVector(networkInputs)
		
		var isWalking = not (input.x == 0 and input.z == 0)		
		
		var direction = input.normalized().rotated(
			Vector3.UP, 
			deg2rad(player.rotation_degrees.y))

		player._velocity = lerp(
			player._velocity, 
			direction * player.MAX_MOVE_VELOCITY, 
			delta * MOVE_ACCEL)

		if(networkInputs["inGame_Roll"]):
			state_machine.transition_to("Roll")
		elif(networkInputs["inGame_Attack1"] or networkInputs["inGame_Attack2"]):
			state_machine.transition_to("BowAttack")
		elif(networkInputs["inGame_Jump"]):
			state_machine.transition_to("Jump")
		elif(not player.is_on_floor() and not player.is_on_wall()):
			state_machine.transition_to("Fall")
		elif(networkInputs["inGame_Sprint"]):
			state_machine.transition_to("Sprint")
		elif(not isWalking):
			state_machine.transition_to("Idle")

func enter(_msg := {}) -> void:
	player._animationTree.set("parameters/Run_To_Fall/blend_amount", 0)
