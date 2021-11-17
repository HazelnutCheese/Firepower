extends PlayerBaseState

const MOVE_ACCEL = 7.0
const TURN_SPEED = 2.5

func physics_update(delta: float) -> void:
	player._rotate_player_process(3, delta)
	
	var vDirection = player._velocity.normalized().rotated(
		Vector3.UP, 
		-player.rotation.y)

	player._animationTree.set(
		"parameters/Idle_To_Run/blend_amount", 
		1)

	player._animationTree.set(
		"parameters/Run_Blend/blend_position", 
		Vector2(vDirection.x, -vDirection.z))
	
	if(get_tree().is_network_server()):
		var networkInputs = InputManager._getInputs(player._networkId)

		var input = player._get_inputVector(networkInputs)
		input.x = 0
		
		var isWalking = not input.z == 0

		var direction = input.normalized().rotated(
			Vector3.UP, 
			deg2rad(player.rotation_degrees.y))

		player._velocity = lerp(
			player._velocity, 
			direction * player.MAX_SPRINT_VELOCITY, 
			delta * MOVE_ACCEL)

		if(networkInputs["inGame_Roll"]):
			state_machine.transition_to("Roll")
		elif(networkInputs["inGame_Attack1"] or networkInputs["inGame_Attack2"]):
			state_machine.transition_to("BowAttack")
		elif(networkInputs["inGame_Jump"]):
			state_machine.transition_to("Jump")
		elif(not player.is_on_floor() and not player.is_on_wall()):
			state_machine.transition_to("Fall")
		elif(isWalking and not networkInputs["inGame_Sprint"]):
			state_machine.transition_to("Walk")
		elif(not isWalking):
			state_machine.transition_to("Idle")

func enter(_msg := {}) -> void:
	player._animationTree.set("parameters/Run_To_Fall/blend_amount", 0)
