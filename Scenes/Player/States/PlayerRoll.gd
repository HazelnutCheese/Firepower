extends PlayerBaseState

var _rollDirection : Vector3

func physics_update(delta: float) -> void:
	player._rotate_player_process(6.0, delta)
	if(get_tree().is_network_server()):
		var networkInputs = InputManager._getInputs(player._networkId)

		var input = player._get_inputVector(networkInputs)
		
		var isWalking = not (input.x == 0 and input.z == 0)

		player._velocity = lerp(
			player._velocity, 
			_rollDirection * 50.0, 
			delta)
		
		var animPerc = player._animationTree._get_currentAnim_percentage("To_Roll")
		if(player._animationTree.get("parameters/To_Roll/active") and animPerc < 0.35):
			return
			
		if(networkInputs["inGame_Attack1"]):
			state_machine.transition_to_any("Bow_Light_03")
			
		if(player._animationTree.get("parameters/To_Roll/active") and animPerc < 1):
			return
		
		player._velocity = player._velocity * 1.1
		if(isWalking):
			state_machine.transition_to("Walk")
		else:
			state_machine.transition_to("Idle")

func enter(_msg := {}) -> void:
	player._animationTree.set("parameters/To_Roll/active", true)
	player._set_rotation_to_camera()
	_rollDirection = player._get_rotated_input_heading()
	if _rollDirection != Vector3():
		var playerDir = player.translation - _rollDirection
		player.look_at(playerDir, Vector3.UP)
	player._rotateWithPlayer = false

func exit(_msg := {}) -> void:
	player._rotateWithPlayer = true
