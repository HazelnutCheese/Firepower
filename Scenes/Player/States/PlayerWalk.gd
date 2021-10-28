extends PlayerBaseState

const MOVE_VELOCITY = 10

func _ready():
	yield(owner, "ready")
	player._animationPlayer.set_blend_time("Run", "Idle", 0.25)
	player._animationPlayer.set_blend_time("Run", "Jump", 0.25)

func physics_update(_delta: float) -> void:
	player._animationPlayer.play("Run")
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
		
		input = input.rotated(Vector3.UP, player.rotation.y)	
		input = input.normalized() * MOVE_VELOCITY
		
		player._velocity.x = input.x
		player._velocity.z = input.z
		
		if(networkInputs["inGame_Jump"]):
			state_machine.transition_to("Jump")
		elif(not player.is_on_floor()):
			state_machine.transition_to("Fall")
		elif(not isWalking):
			state_machine.transition_to("Idle")
