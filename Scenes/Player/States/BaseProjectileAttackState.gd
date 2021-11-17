extends PlayerBaseState
class_name BaseProjectileAttackState

export(int) var projectile_amount: int = 1
export(Vector3) var per_projectile_spawn_translation
export(Vector3) var per_projectile_spawn_rotation
export(String, FILE, "*.tscn,*.scn") var projectile_res_path: String
export(NodePath) var projectile_spawn_bone_attachment : NodePath
export(Vector3) var projectile_spawn_translation_offset
export(Vector3) var projectile_spawn_rotation_offset
export(Vector3) var projectile_spawn_scale = Vector3(1,1,1)
export(Vector3) var projectile_release_scale = Vector3(1,1,1)
export(Vector3) var projectile_impulse: Vector3
export(bool) var projectile_inherit_velocity: bool

export(String) var animation_Path: String

export(bool) var is_charge_attack = false
export(String) var charge_input 
export(float) var charge_min_ms = 1000
export(float) var charge_max_ms = 5000
export(bool) var charge_timeout_at_max
export(String) var charge_hold_animation_path
export(String) var charge_release_animation_path
export(Vector3) var charge_projectile_impulse_multiplier

export(float) var projectile_spawn_anim_perc: float
export(float) var projectile_release_anim_perc: float
export(bool) var allow_pre_rotation = true
export(bool) var allow_follow_camera = false
export(float) var initial_velocity_dampening: float = 0.1
export(bool) var allow_walk = false
export(float) var walk_acceleration = 3.0
export(float) var walk_velocity = 10.0
export(Vector3) var attack_user_impluse: Vector3 = Vector3(1,1,1)
export(float) var user_impulse_start_perc = 0.0
export(float) var user_impulse_stop_perc = 1.0
export(Dictionary) var combo_input_dict: Dictionary

var chosen_combo_input : String = ""

var animationHasStarted = false
var chargeHoldHasStarted = false
var chargeReleaseStarted = false
var charge_time_ms = 0.0
var localCamera = null

var _attackDirection : Vector3
var weaponHitbox : Area = null
var weaponCollision = null
var projectileList = []

var _projectile_scene = null
var _projectile_spawned = false
var _projectile_released = false

var _level_node = null
var _bone_attachment = null

func _ready():
	yield(owner, "ready")
	_projectile_scene = load(projectile_res_path)
	localCamera = player.localCamera
	weaponHitbox = player._weaponHitbox
	_bone_attachment = get_node(projectile_spawn_bone_attachment)
	_level_node = get_tree().get_root().get_node("Control/GameViewportContainer/Viewport/testScene")
	

func physics_update(delta: float) -> void:
	if is_charge_attack:
		_charge_physics_process(delta)
	else:
		_one_shot_physics_process(delta)

func _one_shot_physics_process(delta: float):
	player._rotate_player_process(10.0, delta)
	if(get_tree().is_network_server()):
		var networkInputs = InputManager._getInputs(player._networkId)

		if(networkInputs["inGame_Roll"]):
			for projectile in projectileList:
				projectile.queue_free()
			state_machine.transition_to_any("Roll")

		var input = player._get_inputVector(networkInputs)
		
		var isWalking = not (input.x == 0 and input.z == 0)
		
		if allow_walk:
			var direction = input.normalized().rotated(
			Vector3.UP, 
			deg2rad(player.rotation_degrees.y))

			player._velocity = lerp(
				player._velocity, 
				direction * walk_velocity, 
				delta * walk_acceleration)

		
		if(player._animationTree.get("parameters/" + animation_Path + "/active")):
			animationHasStarted = true
			var animPerc = player._animationTree._get_currentAnim_percentage(
				animation_Path)
				
			if(animPerc > user_impulse_start_perc 
				and animPerc < user_impulse_stop_perc):
				_attackDirection = _get_attackRotation()
				player._velocity = lerp(
					player._velocity, 
					(_attackDirection * attack_user_impluse), 
					delta * walk_acceleration)
				
			if(animPerc > projectile_spawn_anim_perc 
				and not _projectile_spawned):
				_spawn()
				_projectile_spawned = true
				return
				
			if(animPerc > projectile_release_anim_perc 
				and not _projectile_released):
				_release()
				_projectile_released = true
				return
				
			for key in combo_input_dict.keys():
				if networkInputs.has(key) and networkInputs[key]:
					chosen_combo_input = combo_input_dict[key]
			return

		if(animationHasStarted and not _projectile_released):
			_release()

		if(chosen_combo_input != ""):
			state_machine.transition_to(chosen_combo_input)
		elif(networkInputs["inGame_Jump"]):
			state_machine.transition_to_any("Jump")
		elif(isWalking):
			state_machine.transition_to_any("Walk")
		else:
			state_machine.transition_to_any("Idle")

func _charge_physics_process(delta: float):
	player._rotate_player_process(10.0, delta)
	if(get_tree().is_network_server()):
		var networkInputs = InputManager._getInputs(player._networkId)

		if(networkInputs["inGame_Roll"]):
			state_machine.transition_to_any("Roll")

		var input = player._get_inputVector(networkInputs)
		
		var isWalking = not (input.x == 0 and input.z == 0)
		
		if allow_walk:
			var direction = input.normalized().rotated(
			Vector3.UP, 
			deg2rad(player.rotation_degrees.y))

			player._velocity = lerp(
				player._velocity, 
				direction * walk_velocity, 
				delta * walk_acceleration)
		
		if(player._animationTree.get("parameters/" + animation_Path + "/active")):
			animationHasStarted = true
			player.BeginAiming()
			print("animationHasStarted")
			var animPerc = player._animationTree._get_currentAnim_percentage(
				animation_Path)
				
			player._animationTree.set("parameters/" + charge_hold_animation_path + "/blend_amount", animPerc)
			
			if(animPerc > projectile_spawn_anim_perc 
				and not _projectile_spawned):
				_spawn()
				_projectile_spawned = true
				return
			return
			
		if(not animationHasStarted):
			return

		if not chargeHoldHasStarted:
			chargeHoldHasStarted = true
			print("chargeHoldHasStarted")
			return
		
		if(not networkInputs[charge_input]) and not chargeReleaseStarted and (charge_time_ms > charge_min_ms):
			player._animationTree.set("parameters/" + charge_release_animation_path + "/active", true)
			player._animationTree.set("parameters/" + charge_hold_animation_path + "/blend_amount", 0.0)
			chargeReleaseStarted = true
			_release()
			player.StopAiming()
			print("release")
		
		if not chargeReleaseStarted:
			charge_time_ms += (delta * 1000)
			print(str(charge_time_ms))
			return
		
		InputManager._updateRemoteInput(player._networkId, charge_input, false)

		if(chosen_combo_input != ""):
			state_machine.transition_to(chosen_combo_input)
		elif(networkInputs["inGame_Jump"]):
			state_machine.transition_to_any("Jump")
		elif(isWalking):
			state_machine.transition_to_any("Walk")
		else:
			state_machine.transition_to_any("Idle")

func _attack():
	charge_time_ms = 0.0
	animationHasStarted = false
	chargeHoldHasStarted = false
	chargeReleaseStarted = false
	player._velocity *= initial_velocity_dampening
	if allow_pre_rotation:
		player._set_rotation_to_camera()
	player._animationTree.set("parameters/" + animation_Path + "/active", true)
#	player._velocity = lerp(
#		player._velocity, 
#		player._velocity + (_attackDirection * attack_user_impluse), 
#		1.0)

func _get_attackRotation():
	var result = player.global_transform.basis.z.normalized()
	result.y = 1
	return result

func _spawn():
	var rotationAmount = per_projectile_spawn_rotation / projectile_amount
	for n in projectile_amount:
		var projectile = _projectile_scene.instance()
		var bone_attachment = get_node(projectile_spawn_bone_attachment)
		bone_attachment.add_child(projectile)
		projectile.transform.origin = Vector3.ZERO
		projectile.translation = projectile_spawn_translation_offset
		projectile.rotation_degrees = projectile_spawn_rotation_offset
		projectile.rotation_degrees += (rotationAmount * n)
		projectile.scale = projectile_spawn_scale
		projectileList.append(projectile)

func _release():
	var rotationAmount = per_projectile_spawn_rotation / projectile_amount
	var n = 0
	
	var rotateOffset = Vector3(
		deg2rad(rotationAmount.z),
		deg2rad(rotationAmount.y),
		deg2rad(rotationAmount.x))

#	rotationAmount.x = deg2rad(rotationAmount.x)
#	rotationAmount.y = deg2rad(rotationAmount.y)
#	rotationAmount.z = deg2rad(rotationAmount.z)
	
	rotateOffset = rotateOffset.rotated(
			Vector3.UP, 
			player.rotation.y)

	var spawnOffset = Vector3(
		deg2rad(projectile_spawn_rotation_offset.z),
		deg2rad(projectile_spawn_rotation_offset.y),
		deg2rad(projectile_spawn_rotation_offset.x))
	
	spawnOffset = spawnOffset.rotated(
		Vector3.UP, 
		player.rotation.y)
	
#	rotationAmount = rotationAmount.normalized()
	for projectile in projectileList:
		_attackDirection = _get_attackRotation().normalized()
		_attackDirection += spawnOffset
		_attackDirection += (rotateOffset * n)
		
		var currentTranslation = projectile.global_transform.origin
		_bone_attachment.remove_child(projectile)
		_level_node.add_child(projectile)
		projectile.translation = currentTranslation
		projectile.scale = projectile_release_scale
		var velocity = Vector3()
		if projectile_inherit_velocity:
			velocity += player._velocity
		projectile._velocity = (_attackDirection * projectile_impulse)
		if is_charge_attack:
			var charge_multiplier = clamp(charge_time_ms / charge_max_ms, 0.01, 1.0)
			var vector_multiplier = charge_projectile_impulse_multiplier * charge_multiplier
			projectile._velocity *= vector_multiplier
		projectile._velocity += velocity
		projectile.Activate()
		n += 1
	projectileList.clear()

func enter(_msg := {}) -> void:
	chosen_combo_input = ""
	if allow_pre_rotation:
		player._set_rotation_to_camera()
	if not allow_follow_camera:
		player._rotateWithPlayer = false
	if(get_tree().is_network_server()):
		_projectile_spawned = false
		_projectile_released = false
		projectileList.clear()
		InputManager._updateRemoteInput(player._networkId,"inGame_Attack1", false)
	_attack()

func exit(_msg := {}) -> void:
	player._rotateWithPlayer = true
