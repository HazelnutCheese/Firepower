extends PlayerBaseState
class_name BaseAttackState

export(String) var animation_Path: String
export(String) var hit_damage_type: String
export(float) var hit_damage: float
export(Vector3) var hit_impulse: Vector3
export(float) var hit_enabled_on_perc
export(float) var hit_enabled_off_perc
export(bool) var allow_pre_rotation = true
export(float) var initial_velocity_dampening: float = 0.1
export(Vector3) var attack_user_impluse: Vector3 = Vector3(1,1,1)
export(Dictionary) var combo_input_dict: Dictionary

var chosen_combo_input : String = ""

var animationHasEnded = false
var localCamera = null

var _attackDirection : Vector3
var weaponHitbox : Area = null
var weaponCollision = null
var hitList = []

func _ready():
	yield(owner, "ready")
	localCamera = player.localCamera
	weaponHitbox = player._weaponHitbox

func physics_update(delta: float) -> void:
	player._rotate_player_process(10.0, delta)
	if(get_tree().is_network_server()):
		var networkInputs = InputManager._getInputs(player._networkId)

		if(networkInputs["inGame_Roll"]):
			state_machine.transition_to_any("Roll")

		var input = player._get_inputVector(networkInputs)
		
		var isWalking = not (input.x == 0 and input.z == 0)
		
		if(player._animationTree.get("parameters/" + animation_Path + "/active")):
			var animPerc = player._animationTree._get_currentAnim_percentage(
				animation_Path)
			if(animPerc > hit_enabled_on_perc and animPerc < hit_enabled_off_perc):
				var overlappingBodies = weaponHitbox.get_overlapping_bodies()
				for body in overlappingBodies:
					if(body != player):
						_hit(body)
			for key in combo_input_dict.keys():
				if networkInputs.has(key) and networkInputs[key]:
					chosen_combo_input = combo_input_dict[key]
			return

		if(chosen_combo_input != ""):
			state_machine.transition_to(chosen_combo_input)
		elif(networkInputs["inGame_Jump"]):
			state_machine.transition_to_any("Jump")
		elif(isWalking):
			state_machine.transition_to_any("Walk")
		else:
			state_machine.transition_to_any("Idle")

func _attack():
#	if(get_tree().is_network_server()):
	player._velocity *= initial_velocity_dampening
	if allow_pre_rotation:
		player._set_rotation_to_camera()
	_attackDirection = _get_attackRotation()
	_attackDirection.y = 1
	player._animationTree.set("parameters/" + animation_Path + "/active", true)
	player._velocity = lerp(
		player._velocity, 
		player._velocity + (_attackDirection * attack_user_impluse), 
		1.0)

func _get_attackRotation():
	return player.global_transform.basis.z.normalized()

func _hit(body):
	if(body != null):
		var name = body.get_name()
		if((not hitList.has(name)) and body.has_method("_hurt")):
			body._hurt(player, hit_damage, hit_damage_type)
			var impulseDirection = player.translation.direction_to(body.translation)
			impulseDirection.y = 0.5
			var impulse = impulseDirection * (hit_impulse * (1 + player._velocity.length() / player.MAX_SPRINT_VELOCITY))
			body._impulse(player, impulse)
			hitList.append(name)

func enter(_msg := {}) -> void:
	chosen_combo_input = ""
	if allow_pre_rotation:
		player._set_rotation_to_camera()
	player._rotateWithPlayer = false
	if(get_tree().is_network_server()):
		hitList.clear()
		InputManager._updateRemoteInput(player._networkId,"inGame_Attack1", false)
	_attack()

func exit(_msg := {}) -> void:
	player._rotateWithPlayer = true
