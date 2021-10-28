extends PlayerBaseState

func _ready():
	yield(owner, "ready")
	player._animationPlayer.set_blend_time("Falling", "Land", 0.25)
	player._animationPlayer.set_blend_time("Land", "Idle", 1.5)
	player._animationPlayer.set_blend_time("Land", "Run", 1.0)

func physics_update(_delta: float) -> void:
	player._animationPlayer.play("Falling")
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
		
		if(player.is_on_floor()):
			player._velocity = Vector3()
			if(networkInputs["inGame_Jump"]):
				state_machine.transition_to("Jump")
			elif(isWalking):
				state_machine.transition_to("Walk")
			else:
				state_machine.transition_to("Idle")

func exit() -> void:
	player._currentHealth -= 5
	player._animationPlayer.play("Land")
