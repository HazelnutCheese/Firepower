extends PlayerBaseState

func _ready():
	yield(owner, "ready")
	player._animationPlayer.set_blend_time("Idle", "Run", 0.25)

func physics_update(_delta: float) -> void:
	player._animationPlayer.play("Idle")
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
		
		if(networkInputs["inGame_Jump"]):
			state_machine.transition_to("Jump")
		elif(not player.is_on_floor()):
			state_machine.transition_to("Fall")
		elif(isWalking):
			state_machine.transition_to("Walk")
