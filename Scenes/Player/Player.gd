class_name Player
extends VitalEntity

# TODO
# * Host stuck in Fall_To_Run
# * Remove screen freeze from melee attack
# * Redo ai walk node to recalculate each tick


# Animation
onready var _animationTree : EnetAnimationTree = $AnimationTree

# Camera
var localCamera = null
var _rotateWithPlayer = true

# HUD
var remoteHudScene = load("res://Scenes/Player/RemoteHud.tscn")
var localHud = null
var remoteHud = null

# Gameplay
onready var _weaponHitbox = $PlayerModel/eowyntest/Skeleton/BoneAttachment/BrutalSword/WeaponHitbox

# movement
const MAX_MOVE_VELOCITY = 9.0
const MAX_STRAFE_VELOCITY = 4.0
const MAX_BACKPEDAL_VELOCITY = 6.0
const MAX_AIR_MOVE_VELOCITY = 20.0
const MAX_SPRINT_VELOCITY = 20.0
const AIR_ACCEL = 4.0
const ANGULAR_ACCEL = 10.0
var _canRotate = true
onready var playerModel = $PlayerModel

# networking
var _networkId = -1
puppet var puppet_camera_rotation_degrees = Vector3()
remote var puppet_forServer_cameraY = 0.0

#func _ready():
#	_weaponHitbox.monitoring = false

func _setup(networkId):
	_networkId = networkId
	if(_networkId == ServerClient._networkId):
		localCamera = get_tree().get_root().get_node("Control")._localCamera
		localCamera.get_node("ClippedCamera").add_exception(self)
		localHud = get_tree().get_root().get_node("Control/HUD")
		replicate_rotation = false
	else:
		remoteHud = remoteHudScene.instance()
		self.add_child(remoteHud)

func _physics_process(delta):
	_velocity = lerp(_velocity, Vector3(0, _velocity.y, 0), delta * 3.0)
	apply_movement(delta)

	if(localHud != null):
		localHud._updateHealth(_currentHealth)
	else:
		remoteHud._updateHealth(_currentHealth)

func _impulse(agent: Node, impulse: Vector3):
	_velocity += impulse

func _rotate_player_process(lookAccel: float, delta: float):
	if(get_tree().is_network_server()):
		if(_networkId != 1 and _rotateWithPlayer):
			var networkInputs = InputManager._getInputs(_networkId)
#			var direction = Vector3(1,0,1).rotated(Vector3.UP, deg2rad(networkInputs["cameraY"]))
			rotation.y = lerp_angle(rotation.y, deg2rad(networkInputs["cameraY"]), lookAccel * delta)

	if(localCamera != null):
		localCamera.translation = translation
		localCamera.rotation_degrees.y = localCamera._nextCameraY
		if(_rotateWithPlayer):
#			var direction = Vector3(1,0,1).rotated(Vector3.UP, localCamera.rotation.y)
			rotation.y = lerp_angle(rotation.y, localCamera.rotation.y, lookAccel * delta)

func _set_rotation_to_camera():
	if(get_tree().is_network_server()):
		if(_networkId != 1):
			var networkInputs = InputManager._getInputs(_networkId)
			rotation_degrees.y = networkInputs["cameraY"]

	if(localCamera != null):
		localCamera.translation = translation
		localCamera.rotation_degrees.y = localCamera._nextCameraY
		rotation_degrees.y = localCamera._nextCameraY

func _get_inputVector(networkInputs):
	var input = Vector3()
	if(networkInputs["inGame_MoveForward"]):
		input.z += 1
	if(networkInputs["inGame_MoveBackward"]):
		input.z -= 1
	if(networkInputs["inGame_StrafeLeft"]):
		input.x += 1
	if(networkInputs["inGame_StrafeRight"]):
		input.x -= 1
	return input

func _get_rotated_input_heading():
		var networkInputs = InputManager._getInputs(_networkId)
		var input = _get_inputVector(networkInputs)
		var direction = input.normalized().rotated(
			Vector3.UP, 
			rotation.y)
		return direction

func _enableWeaponHitbox():
	_weaponHitbox.monitoring = true

func _disableWeaponHitbox():
	_weaponHitbox.monitoring = false
