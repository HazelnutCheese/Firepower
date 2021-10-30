extends PlayerBaseState

const JUMP_VERTICAL_VELOCITY = 12.0
const JUMP_PUSH_MULTI = 1.1

func physics_update(delta: float) -> void:
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
		
		var direction = input.normalized().rotated(Vector3.UP, deg2rad(networkInputs["cameraY"]))
		player._velocity = lerp(player._velocity, direction * player.MAX_AIR_MOVE_VELOCITY, delta * player.AIR_ACCEL)
		
		if(player._velocity.y <= 0):
			state_machine.transition_to("Fall")

func enter(_msg := {}) -> void:
	if(get_tree().is_network_server()):
		player._velocity.x *= JUMP_PUSH_MULTI
		player._velocity.z *= JUMP_PUSH_MULTI
		player._velocity.y = JUMP_VERTICAL_VELOCITY
		player._animationTree.pset("parameters/To_Jump/active", true)
		player._animationTree.pset("parameters/Run_To_Fall/blend_amount", 1)
